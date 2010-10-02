package com.medratech.bsse.component.zehnet.net
{
	import flash.errors.IllegalOperationError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import com.medratech.bsse.component.zehnet.events.FileUploadErrorEvent;
	import com.medratech.bsse.component.zehnet.events.FileUploadEvent;			

	public class FileUpload extends EventDispatcher implements IFileUpload
	{
		private static const IDLE:int 			= 0;
		private static const FILE_CHECKING:int 	= 1;
		private static const UPLOADING:int 		= 2;
		
		protected var status:int = IDLE;
		
		protected var fileReference:FileReference;
		
		protected var urlLoader:URLLoader;
		
		protected var urlRequest:URLRequest;
		
		protected var currentRequest:URLRequest;
		
		protected var _overwrite:Boolean = false;
		
		/**
		 * 
		 */
		public function FileUpload(reference:FileReference=null)
		{
			fileReference = (reference==null) ? new FileReference() : reference;
			
			urlLoader = new URLLoader();
			
			configureListeners();
		}
		
		/**
		 * 
		 */
		protected function configureListeners():void
		{
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,onFileUploadComplete);
			
			fileReference.addEventListener(ProgressEvent.PROGRESS,onFileUploadProgress);
			
			fileReference.addEventListener(Event.SELECT,onSelect);
				
			/* events passed as is */
			//obj.addEventListener(Event.OPEN,passThroughEvent); // we do it manually
			fileReference.addEventListener(Event.COMPLETE,passThroughEvent);
			fileReference.addEventListener(Event.CANCEL,passThroughEvent); // Dispatched when a file upload or download is canceled through the file-browsing dialog box by the user.
			fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS,passThroughEvent);
			
			/* error events passed as is */
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);
		}

		// ====================================
		// == PROPERTIES
		// ====================================

		/**
		 * is true if FileReference.browse was already called
		 * and file was selected
		 */	
		public function get isSelected():Boolean
		{
			return (fileReference.name !== null);
		}

		/**
		 * 
		 */		
		public function get data():ByteArray
		{
			return fileReference['data'] as ByteArray;
		}

		/**
		 * 
		 */		
		public function get creationDate():Date
		{
			return fileReference.creationDate;
		}

		/**
		 * 
		 */	
		public function get creator():String
		{
			return fileReference.creator;
		}

		/**
		 * 
		 */		
		public function get modificationDate():Date
		{
			return fileReference.modificationDate;
		}

		/**
		 * 
		 */		
		public function get name():String
		{
			return fileReference.name;
		}

		/**
		 * 
		 */		
		public function get size():Number
		{
			return fileReference.size;
		}

		/**
		 * 
		 */		
		public function get type():String
		{
			return fileReference.type;
		}

		/**
		 * Defines if a file with the same name already existing
		 * on the server should be replaced with the file to upload.
		 * 
		 * You can define this property with the "upload"
		 * method: FileUpload.upload(urlRequest, true);
		 */
		public function get overwrite():Boolean
		{
			return _overwrite;
		}

		// ====================================
		// == PUBLIC METHODS
		// ====================================

		/**
		 * 
		 */		
		public function browse(typeFilter:Array = null):Boolean
		{
			if(status > IDLE)
			{
				throw new IllegalOperationError();
			}
			
			return fileReference.browse(typeFilter);
		}

		/**
		 * 
		 */		
		public function cancel():void
		{
			if(status > IDLE)
			{
				if(status == FILE_CHECKING)
				{
					urlLoader.close();
				}
				else
				{
					fileReference.cancel();
				}
				status = IDLE;
				_overwrite = false;
			}
		}

		/**
		 * 
		 * If you don't want to carry out a file check operation prior to
		 * the file upload itself, simply set the overwriteIfExists flag to true.
		 */		
		public function upload(request:URLRequest, overwriteIfExists:Boolean=false):void
		{
			if(!isSelected || status > IDLE)
			{
				throw new IllegalOperationError();
			}
			
			urlRequest = parseURLRequest(request);
			
			_overwrite = overwriteIfExists;
			
			// dispatch overall open event
			dispatchEvent(new Event(Event.OPEN));
			
			if(_overwrite)
			{
				startFileUpload();
			}
			else
			{
				startFileCheck();
			}
		}

		// ====================================
		// == PROTECTED UPLOAD METHODS
		// ====================================

		/**
		 * 
		 */		
		protected function startFileCheck():void
		{
			status = FILE_CHECKING;
			
			currentRequest = new URLRequest();
			
			currentRequest.data = cloneURLVariables(urlRequest.data as URLVariables);
			
			currentRequest.data.fileAction = 'check';
			currentRequest.data.fileName 	= name;
			currentRequest.data.fileSize 	= size;
			
			currentRequest.url 	= urlRequest.url;
			currentRequest.method 	= URLRequestMethod.GET;
			
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,errorEvent);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEvent);	
			
			urlLoader.addEventListener(Event.COMPLETE,onFileCheckComplete);
			
			// dispatch FILE_CHECK_OPEN event
			dispatchEvent(new FileUploadEvent(
				FileUploadEvent.FILE_CHECK_OPEN, 
				urlRequest
			));
			
			urlLoader.load(currentRequest);
		}

		/**
		 * 
		 */		
		protected function onFileCheckComplete(event:Event=null):void
		{
			var response:FileUploadResponse = new FileUploadResponse(urlLoader.data);
			
			if(!response.isError) // not exists
			{
				
				// dispatch complete event
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.FILE_CHECK_COMPLETE, 
					currentRequest
				));
				
				startFileUpload();
			}
			else
			{
				// dispatch error event
				dispatchError(FileUploadErrorEvent.FILE_CHECK_ERROR, response.errorID, response.message);
			}
		}

		/**
		 * 
		 */		
		protected function startFileUpload():void
		{
			status = UPLOADING;
			
			currentRequest = new URLRequest();
			var data:URLVariables = cloneURLVariables(urlRequest.data as URLVariables);
			
			data.fileAction = 'upload';
			data.fileName 	= name;
			data.fileSize 	= size;
			
			if(_overwrite)
			{
				data.fileOverwrite 	= 1;
			}
			
			currentRequest.url = urlRequest.url+'?'+data.toString();
			
			// dispatch open event
			dispatchEvent(new FileUploadEvent(
				FileUploadEvent.UPLOAD_OPEN, 
				currentRequest
			));
			
			fileReference.upload(currentRequest);
		}

		/**
		 * 
		 */		
		protected function onFileUploadProgress(event:ProgressEvent=null):void
		{
			// dispatch overall progress event (here: upload.progress == overall.progress)
			dispatchEvent(event);
			
			// dispatch progress event
			dispatchEvent(new FileUploadEvent(
				FileUploadEvent.UPLOAD_PROGRESS, 
				currentRequest,
				event.bytesLoaded,
				event.bytesTotal
			));
		}

		/**
		 * 
		 */		
		protected function onFileUploadComplete(event:DataEvent=null):void
		{
			var response:FileUploadResponse = new FileUploadResponse(event.data);
			
			status = IDLE;
			_overwrite = false;
			
			// dispatch overall complete event (here: upload.complete == overall.complete)
			dispatchEvent(event);
			
			if(!response.isError) // not exists
			{
				// dispatch complete event
				dispatchEvent(new FileUploadEvent(
					FileUploadEvent.UPLOAD_COMPLETE, 
					currentRequest,
					fileReference.size,
					fileReference.size
				));
			}
			else
			{
				// dispatch error event
				dispatchError(FileUploadErrorEvent.FILE_UPLOAD_ERROR, response.errorID, response.message);	
			}

			currentRequest = null;
		}

		// ====================================
		// == EVENT LISTENERS
		// ====================================

		/**
		 * 
		 */
		protected function passThroughEvent(event:Event):void
		{
			dispatchEvent(event);
		}

		/**
		 * 
		 */
		protected function errorEvent(event:Event):void
		{
			status = IDLE;
			currentRequest = null;
			_overwrite = false;
			dispatchEvent(event);
		}

		/**
		 * 
		 */
		protected function onSelect(event:Event):void
		{
			if(status > IDLE)
			{
				cancel();
			}
			dispatchEvent(event);
		}
		
		// ====================================
		// == HELPERS
		// ====================================

		/**
		 * 
		 */
		protected function dispatchError(type:String, errorID:int, errorMessage:String):void
		{
			status 		= IDLE;
			_overwrite 	= false;
			
			dispatchEvent(new FileUploadErrorEvent(
				type, 
				currentRequest, 
				errorID,
				errorMessage
			));
			
			currentRequest = null;
		}
		
		/**
		 * parses querystring of request.url and request.data property (if URLVariables)
		 * into a new URLRequest object with no querystring in its request.url
		 * but all variables added as URLVariables to the request.data object.
		 */
		protected function parseURLRequest(orgRequest:URLRequest):URLRequest
		{
			var vars:URLVariables 	= new URLVariables();
			
			var url:String = orgRequest.url;
			
			var q:int = url.lastIndexOf('?');
			
			if(q>=0)
			{
				vars.decode(url.substring(q+1));
				url = url.substring(0,q);
			}
			
			if(orgRequest.data && orgRequest.data is URLVariables)
			{
				for(var i:String in orgRequest.data)
				{ 
					vars[i] = orgRequest.data[i];
				}
			}
			
			var request:URLRequest 	= new URLRequest(url);
			request.data = vars;
			
			return request;
		}

		/**
		 * returns a copy of the URLVariables of the URLRequest
		 * received with upload method
		 */
		protected function cloneURLVariables(org:URLVariables):URLVariables
		{			
			var vars:URLVariables 	= new URLVariables();
			var s:String = org.toString();
			if(s!='') vars.decode(s);
			return vars;
		}

	}
}