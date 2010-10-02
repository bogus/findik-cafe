/**

   	** LICENSE **
	
	Copyright © 2009 N. Zeh <http://www.zehnet.de/>
   
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Lesser Public License as published by
    the Free Software Foundation (version 2.1).
	For more information see: http://creativecommons.org/licenses/LGPL/2.1/
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	 
*/
package com.medratech.bsse.component.zehnet.net
{
	import flash.errors.IllegalOperationError;
	import flash.errors.MemoryError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.*;
	
	import com.medratech.bsse.component.zehnet.events.FileUploadErrorEvent;
	import com.medratech.bsse.component.zehnet.events.FileUploadEvent;
	import com.medratech.bsse.component.zehnet.util.crypt.Adler32;
	import com.medratech.bsse.component.zehnet.util.crypt.IChecksum;	
	
	public class BigFileUpload extends FileUpload implements IFileUpload
	{		
		/**
		 * Status constants for status checks 
		 */
		private static const IDLE:int 			= 0;
		private static const FILE_CHECKING:int 	= 1;
		private static const RAM_LOADING:int 	= 2;
		private static const CHECKSUMMING:int 	= 3;
		private static const UPLOADING:int 		= 4;

		/**
		 * the chunk size for one checksum calculation operation
		 */
		public static var checksumChunkSize:int = 1048576; // 1mb

		/**
		 * the maximum chunk size for one upload post request
		 */
		public static var maxPostSize:int = 2097152; // 2mb

		/**
		 * the minimum chunk size for one upload post request
		 */
		public static var minPostSize:int = 51200; // 50 kb
		
		private var checkSummingStopped:Boolean = false;
		
		private var checksumUtil:IChecksum;
		
		private var _checksum:String = '';
		
		private var fileOffset:Number = 0;
		
		private var cachedOffset:Number;
		private var cachedChecksum:String;
		
		/**
		 * constructor
		 */		
		public function BigFileUpload(reference:FileReference=null)
		{
			super(reference);
			
			checksumUtil = new Adler32();
		}

		/**
		 * 
		 */
		override protected function configureListeners():void
		{
			// @TODO: check which listeners you need
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,onFileUploadComplete);
			
			fileReference.addEventListener(ProgressEvent.PROGRESS,onFileUploadProgress);
			
			urlLoader.addEventListener(Event.COMPLETE,onFileCheckComplete);
			
			/* events passed as is */
			//obj.addEventListener(Event.OPEN,passThroughEvent); // we do it manually
			fileReference.addEventListener(Event.COMPLETE,passThroughEvent);
			fileReference.addEventListener(Event.CANCEL,passThroughEvent); // Dispatched when a file upload or download is canceled through the file-browsing dialog box by the user.
			fileReference.addEventListener(Event.SELECT,passThroughEvent);
			fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS,passThroughEvent);
			
			/* error events passed as is */
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,errorEvent);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);
		}

		// =================================================
		// == PROPERTIES
		// =================================================

		/* Property: postMaxSize */
		/**
		private var _maxPostSize:Number = 204800; // 2 mb (PHP default upload max size)
		
		

		public function set maxPostSize(size:Number):void
		{
			_maxPostSize = size;
		} 
		 
		public function get maxPostSize():Number
		{
			return _maxPostSize;
		}
		*/
		/* Property: chunkSize */
		
		private var _chunkSize:Number = -1; //512000; // 500 kb // 102400; // 100 kb
		
		/**
		 * The BigFileReference achieves uploading of bigger
		 * files than are allowed by the web server by splitting
		 * the file into parts and uploading them seperately.
		 * 
		 * The chunkSize defines the size in Bytes of each part
		 * that is uploaded.
		 * 
		 * The default is -1 which means that the chunkSize is
		 * automatically calculated and adjusted to the connection speed.
		 */
		public function set chunkSize(size:Number):void
		{
			_chunkSize = size;
		}

		/**
		 * 
		 */
		public function get chunkSize():Number
		{
			return _chunkSize;
		}
		
		/* Property: compressData */
		
		private var _compressData:Boolean = false;
		
		/**
		 * As flash supports zlib compresssion, one can specify
		 * here if the parts uploaded to the server should
		 * be compressed bevore being uploaded.
		 * 
		 * If the server supports zlib compression and sends
		 * a flag with compression=1 back to the client,
		 * compression will be used in any case,
		 * i.e. it has not to be set specifically here
		 */
		public function set compressData(compress:Boolean):void
		{
			_compressData = compress;
		}

		/**
		 * 
		 */
		public function get compressData():Boolean
		{
			return _compressData;
		}

		/**
		 * 
		 */
		public function get checksum():String
		{
			return _checksum;
		}

		// =================================================
		// == FILEREFERENCE METHODS
		// =================================================

		/**
		 * 
		 */
		override protected function onSelect(event:Event):void
		{
			_checksum = '';
			super.onSelect(event);
		}

		/**
		 * 
		 */		
		override public function cancel():void
		{
			if(status > IDLE)
			{
				if(status == RAM_LOADING)
				{
					fileReference.cancel();
				}
				else if(status == CHECKSUMMING)
				{
					checkSummingStopped = true;
				}
				else // if status == FILE_CHECKING || status == UPLOADING
				{
					urlLoader.close();
				}
				
				status = IDLE;
			}
		}			

		/**
		 * 
		 */		
		override protected function onFileCheckComplete(event:Event=null):void
		{
			var response:FileUploadResponse = new FileUploadResponse(urlLoader.data);
			
			if(!response.isError && response.fileOffset >= 0)
			{
				cachedOffset = response.fileOffset;
				cachedChecksum = response.checksum;
				
				compressData = response.compression;
			}
			
			super.onFileCheckComplete(event);
		}
		
		/**
		 * 
		 */		
		override protected function startFileUpload():void
		{
			if(!isLoaded)
			{
				startRamLoading();
			}
			else if(checksum == '') // @TODO: set checksum = '' onSelect after browse
			{
				checkSummingStopped = false;
				calculateChecksum(0, 512000); // 500kb
			}
			else
			{
				status = UPLOADING;
				
				fileOffset = 0;
				
				if(cachedOffset && cachedChecksum && cachedChecksum == checksum)
				{
					fileOffset = cachedOffset;
				}
				cachedOffset 	= 0;
				cachedChecksum	= '';
				
				urlLoader = new URLLoader();
				
				//urlLoader.dataFormat = URLLoaderDataFormat.BINARY; // we get text back
				
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);
				
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,passThroughEvent);
				
				urlLoader.addEventListener(Event.COMPLETE,onChunkComplete);
				
				// dispatch open event
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.UPLOAD_OPEN, 
					urlRequest
				));
				
				uploadChunk(fileOffset,chunkSize);
			}
		}
		
		private var chunkTimer:Number = -1;
		private var lastChunkSize:Number = 0;
		
		/**
		 * 
		 */
		private function uploadChunk($offset:Number,$chunkSize:Number):void
		{
			var bytes:ByteArray = new ByteArray();
			var data:ByteArray = fileReference.data;
			
			if($chunkSize <0) // automatic chunkSize calculation due to connection
			{
				if(chunkTimer <0) // first call => we start with 50 kb
				{
					$chunkSize = lastChunkSize = 51200;						
				}
				else
				{
					var diff:Number = getTimer()-chunkTimer;

					// intervall should update every second (1000ms)
					$chunkSize = lastChunkSize = Math.round(lastChunkSize / diff * 1000);
					
					$chunkSize = Math.min(Math.max(minPostSize,$chunkSize), maxPostSize);
				}
				
				chunkTimer = getTimer();
			}
			
			if($offset+$chunkSize > data.length)
			{
				$chunkSize = data.length-$offset;
			}
			
			var p:int = data.position;
			
			data.position = $offset;
			data.readBytes(bytes,0,$chunkSize);
			
			data.position = p; // reset position
			
			var vars:URLVariables = cloneURLVariables(urlRequest.data as URLVariables);
			
			vars.fileAction = 'upload';
			vars.fileOffset = $offset;
			vars.fileSize 	= fileReference.size;
			vars.fileName 	= fileReference.name;
			vars.fileChecksum = checksum;
			
			if(_overwrite)
			{
				vars.fileOverwrite = 1;
			}
			
			// if compression flag is set
			if(compressData)
			{
				bytes.compress();
				vars.fileCompressed = 1;
			}
			
			currentRequest 				= new URLRequest();
			currentRequest.url			= urlRequest.url+'?'+vars.toString();
			currentRequest.method 		= URLRequestMethod.POST;
			currentRequest.contentType 	= 'application/octet-stream'; // binary header
			currentRequest.data 		= bytes;
			
			urlLoader.load(currentRequest);
	
		}

		/**
		 * 
		 */
		private function onChunkComplete(event:Event):void
		{
			var response:FileUploadResponse = new FileUploadResponse(urlLoader.data);
			
			if(!response.isError) // if success
			{
				
				// if we have retrieved an offset from the server => use it ; otherwise increasize offset by chunksize
				fileOffset = (response.fileOffset >= 0) ? response.fileOffset : fileOffset + chunkSize;
				
				compressData = response.compression;
				
				// file upload completed
				if(fileOffset>=fileReference.data.length)
				{
					fileOffset = fileReference.data.length;
					
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
					urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);
					
					urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,passThroughEvent);
					
					urlLoader.removeEventListener(Event.COMPLETE,onChunkComplete);
					
					status = IDLE;
					
					// dispatch overall COMPLETE Event
					dispatchEvent(event);
					
					// dispatch UPLOAD_COMPLETE_DATA Event with data from urlLoader
					dispatchEvent(new DataEvent(DataEvent.UPLOAD_COMPLETE_DATA,false,false,urlLoader.data));
					
					// dispatch FileUploadEvent.UPLOAD_COMPLETE
					dispatchEvent(new FileUploadEvent(
						FileUploadEvent.UPLOAD_COMPLETE,
						currentRequest,
						fileReference.data.length,
						fileReference.data.length,
						response.data
					));
				}
				else
				{
					// dispatch FileUploadEvent.UPLOAD_PROGRESS
					dispatchEvent(new FileUploadEvent(
						FileUploadEvent.UPLOAD_PROGRESS,
						currentRequest,
						fileOffset,
						fileReference.data.length,
						response.data
					));
					
					// upload next chunk
					uploadChunk(fileOffset,chunkSize);
				}
			
			}
			else // error
			{
				dispatchError(FileUploadErrorEvent.FILE_UPLOAD_ERROR, response.errorID, response.message);			
			}
		}
	
		/**
		 * 
		 */
		private function startRamLoading():void
		{
			status = RAM_LOADING;
			
			// register listeners to capture & stop FileReference Events
			// dispatched by the "load" method, as we use it in our upload method
			// and we don't want it to interfere with the upload events dispatched
			fileReference.addEventListener(Event.OPEN,onRamLoadingEvent, false, int.MAX_VALUE);
			fileReference.addEventListener(ProgressEvent.PROGRESS,onRamLoadingEvent, false, int.MAX_VALUE);
			fileReference.addEventListener(Event.COMPLETE,onRamLoadingEvent, false, int.MAX_VALUE);
			
			// pass through ioError
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, errorEvent, false, int.MAX_VALUE);
			
			try
			{
				// throws IllegalOperationError, MemoryError, Error
				fileReference.load(); // try catch;
			}
			catch(error:Error)
			{
				fileReference.removeEventListener(Event.OPEN,onRamLoadingEvent);
				fileReference.removeEventListener(ProgressEvent.PROGRESS,onRamLoadingEvent);
				fileReference.removeEventListener(Event.COMPLETE,onRamLoadingEvent);
				
				fileReference.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
				
				if(error is IllegalOperationError || error is MemoryError)
				{
					throw error;
				}
				else
				{
					throw new Error('BigFileUploading not supported!');
				}
				// return;
			}
			
			dispatchEvent(new FileUploadEvent(
				FileUploadEvent.RAMLOAD_OPEN,
				urlRequest
			));
		}

		/**
		 * Event interceptor. Used to stop propagation
		 * of events dispatched by the "load" method
		 * if it is triggered from inside this class.
		 */
		private function onRamLoadingEvent(event:Event):void
		{
			event.stopImmediatePropagation(); // dont trigger progress events on FileReference listeners
			
			if(event.type == ProgressEvent.PROGRESS)
			{
				var e:ProgressEvent = event as ProgressEvent;
				
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.RAMLOAD_PROGRESS,
					urlRequest,
					e.bytesLoaded,
					e.bytesTotal
				));
			
			}	
			else if(event.type == Event.COMPLETE)
			{
				fileReference.removeEventListener(Event.OPEN,onRamLoadingEvent);
				fileReference.removeEventListener(ProgressEvent.PROGRESS,onRamLoadingEvent);
				fileReference.removeEventListener(Event.COMPLETE,onRamLoadingEvent);
				
				fileReference.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
				
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.RAMLOAD_COMPLETE,
					urlRequest,
					fileReference.data.length,
					fileReference.data.length
				));
				
				startFileUpload();
			}
		}
		
		/**
		 * 
		 */
		private function calculateChecksum(offset:uint=0,$chunkSize:uint=512000):void // 500kb
		{
			if(checkSummingStopped) return;
			
			if(offset==0)
			{
				checksumUtil.reset();
				status = CHECKSUMMING;
				
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.CHECKSUM_OPEN,
					urlRequest
				));
			}
			
			var d:int = (offset+$chunkSize>fileReference.data.length) ? fileReference.data.length-offset : $chunkSize;
			
			checksumUtil.update(fileReference.data,offset,d);
			
			if(offset+d < fileReference.data.length)
			{
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.CHECKSUM_PROGRESS,
					urlRequest,
					offset+$chunkSize,
					fileReference.data.length
				));
				
				setTimeout(calculateChecksum,15,offset+$chunkSize,$chunkSize); // prevent freeze of flex app
			}
			// checksum calculation complete
			else
			{
				_checksum = checksumUtil.getValue().toString(16);
				
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.CHECKSUM_COMPLETE,
					urlRequest,
					fileReference.data.length,
					fileReference.data.length
				));
				
				startFileUpload();
			}
		}
		
		// =================================================
		// == CHECKING METHODS
		// =================================================

		/**
		 * is true if FileReference.load was already called
		 * and FileReference.data is available
		 */	
		public function get isLoaded():Boolean
		{
			return (fileReference.data && fileReference.data.length>0);
		}
		
		private static var _bigFileIsSupported:int=-1;
		/**
		 * is true if FlashPlayer version supports
		 * FileReference.load and therefore supports
		 * uploading of big files.
		 * 
		 * I have added Flash version 10.0.22.xx as minimum required version,
		 * as it was the first version for me (on a PC with Firefox)
		 * where no complications occured. Earlier versions of Flash Player 10
		 * made Firefox crash, although FileReference.load should have been supported.
		 */	
		public static function get bigFileIsSupported():Boolean
		{
			if(_bigFileIsSupported==-1)
			{
				// m[1]:platform  m[2]:majorVersion,m[3]:minorVersion,m[4]:buildNumber,m[5]:internalBuildNumber
				var version:String = Capabilities.version;
				var m:Array = version.match(/^([a-z]+) ([0-9]+),([0-9]+),([0-9]+),([0-9]+)$/i);
				_bigFileIsSupported = (int(m[2])>=10 && int(m[4])>=22) ? 1:0;
			}
			return (_bigFileIsSupported==1);
		}

	}
}