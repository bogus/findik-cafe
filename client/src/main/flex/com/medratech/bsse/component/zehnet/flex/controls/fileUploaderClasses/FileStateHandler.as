package com.medratech.bsse.component.zehnet.flex.controls.fileUploaderClasses
{
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import mx.events.PropertyChangeEvent;
	
	import com.medratech.bsse.component.zehnet.events.FileUploadErrorEvent;
	import com.medratech.bsse.component.zehnet.events.FileUploadEvent;
	import com.medratech.bsse.component.zehnet.net.BigFileUpload;
	import com.medratech.bsse.component.zehnet.net.FileUpload;
	
	
	public class FileStateHandler extends EventDispatcher
	{
		public static const PENDING:String = 'pending';
		public static const FILE_CHECKING:String = 'fileChecking';
		public static const RAMLOADING:String = 'ramloading';
		public static const CHECKSUMMING:String = 'checksumming';
		public static const UPLOADING:String = 'uploading';
		public static const COMPLETED:String = 'completed';
		public static const ERROR:String = 'error';
		

		private var _fileUpload:FileUpload;
	
		private var _bytesLoaded:int = 0;
		
		private var _bytesTotal:int = 0;
		
		private var _bytesPerSecond:int = 0;
		
		private var startTimer:int;
		
		private var _status:String = PENDING;
		
		private var _errorID:int;
		
		private var _errorMessage:String = '';
		
		/**
		 *
		 */
		public function FileStateHandler($upload:FileUpload)
		{
			_fileUpload = $upload;
			
			configureListeners();
		}

		/**
		 * 
		 */
		public function upload(request:URLRequest, overwriteIfExists:Boolean=false):void
		{
			_fileUpload.upload( request, overwriteIfExists);
		}

		/**
		 * 
		 */
		public function cancel():void
		{
			_fileUpload.cancel();
			
			var oldStatus:String = status;
			_status = PENDING;
			
			var oldBytes:int = _bytesLoaded;
			var oldPercent:int = percentLoaded;
			
			_bytesPerSecond = 0;
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',oldBytes,0));
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',oldPercent,0));
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'status',oldStatus,status));
		}

		/**
		 * 
		 */
		private function configureListeners():void
		{		
			if(_fileUpload is BigFileUpload)
			{
				_fileUpload.addEventListener(FileUploadEvent.RAMLOAD_OPEN,onEvent);
				_fileUpload.addEventListener(FileUploadEvent.RAMLOAD_PROGRESS,onEvent);
				//_fileUpload.addEventListener(FileUploadEvent.RAMLOAD_COMPLETE,onEvent);
				_fileUpload.addEventListener(FileUploadEvent.CHECKSUM_OPEN,onEvent);
				_fileUpload.addEventListener(FileUploadEvent.CHECKSUM_PROGRESS,onEvent);
				//_fileUpload.addEventListener(FileUploadEvent.CHECKSUM_COMPLETE,onEvent);
				
				_fileUpload.addEventListener(FileUploadErrorEvent.FILE_CHECKSUM_ERROR,onError);
				_fileUpload.addEventListener(FileUploadErrorEvent.FILE_RAMLOAD_ERROR,onError);
			}
			
			_fileUpload.addEventListener(FileUploadEvent.FILE_CHECK_OPEN,onEvent);
			//_fileUpload.addEventListener(FileUploadEvent.FILE_CHECK_COMPLETE,onEvent);
			_fileUpload.addEventListener(FileUploadEvent.UPLOAD_OPEN,onEvent);
			_fileUpload.addEventListener(FileUploadEvent.UPLOAD_PROGRESS,onEvent);
			_fileUpload.addEventListener(FileUploadEvent.UPLOAD_COMPLETE,onEvent);
			
			_fileUpload.addEventListener(FileUploadErrorEvent.FILE_CHECK_ERROR,onError);
			_fileUpload.addEventListener(FileUploadErrorEvent.FILE_UPLOAD_ERROR,onError);		
		}
		
		private function onEvent(event:FileUploadEvent):void
		{
			var oldBytesLoaded:int, oldPercent:int, oldStatus:String = _status;			
	
			switch(event.type)
			{
				case(FileUploadEvent.FILE_CHECK_OPEN):
					_status = FILE_CHECKING;
					break;
					
				case(FileUploadEvent.RAMLOAD_OPEN):
					_status = RAMLOADING;
					startTimer = getTimer();
					
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',0,0));
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',0,0));
					break;
				
				case(FileUploadEvent.CHECKSUM_OPEN):
					_status = CHECKSUMMING;
					startTimer = getTimer();
					 
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',0,0));
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',0,0));
					break;
				
				case(FileUploadEvent.UPLOAD_OPEN):
					_status = UPLOADING;
					startTimer = getTimer();
					
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',0,0));
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',0,0));
					break;
				
				case(FileUploadEvent.UPLOAD_COMPLETE):
					oldBytesLoaded = _bytesLoaded;
					oldPercent = percentLoaded;
					
					_bytesLoaded 	= _fileUpload.size;
					_bytesTotal 	= _fileUpload.size;
					_bytesPerSecond = 0;
					
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',oldBytesLoaded,_bytesLoaded));
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',oldPercent,1));
					
					_status = COMPLETED;
					break;
					
				case(FileUploadEvent.RAMLOAD_PROGRESS):
				case(FileUploadEvent.CHECKSUM_PROGRESS):
				case(FileUploadEvent.UPLOAD_PROGRESS):
					oldBytesLoaded = _bytesLoaded;
					oldPercent = percentLoaded;
					
					_bytesLoaded 	= event.bytesLoaded;
					_bytesTotal 	= event.bytesTotal;
					
					var now:int = getTimer();
					
					_bytesPerSecond = _bytesLoaded/((now-startTimer)/1000);
					
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'bytesLoaded',oldBytesLoaded,_bytesLoaded));
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'percentLoaded',oldPercent,percentLoaded));
					break;
			}
			
			if(_status!=oldStatus)
			{
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'status',oldStatus,_status));
			}
		}

		private function onError(event:FileUploadErrorEvent):void
		{
			var oldStatus:String = _status;
			_status = ERROR;
			
			_errorMessage = event.errorMessage;
			_errorID = event.errorID;
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'status',oldStatus,_status));
		}
		
		// Properties
		
		public function get fileUpload():FileUpload
		{
			return _fileUpload;
		}
		
		public function get status():String
		{
			return _status;
		}

		[Bindable(event="propertyChange")]		
		public function get percentLoaded():int
		{
			return _bytesLoaded>0 ? _bytesLoaded/_bytesTotal : 0;
		}


		[Bindable(event="propertyChange")]
		public function get bytesLoaded():int
		{
			return _bytesLoaded;
		}

		[Bindable(event="propertyChange")]
		public function get bytesTotal():int
		{
			return _bytesTotal;
		}
		
		[Bindable(event="propertyChange")]
		public function get name():String
		{
			return (_fileUpload!=null) ? _fileUpload.name : '';
		}
		
		[Bindable(event="propertyChange")]
		public function get creationDate():Date
		{
			return (_fileUpload!=null) ? _fileUpload.creationDate : null;
		}
		
		[Bindable(event="propertyChange")]
		public function get creator():String
		{
			return (_fileUpload!=null) ? _fileUpload.creator : '';
		}
		
		[Bindable(event="propertyChange")]
		public function get modificationDate():Date
		{
			return (_fileUpload!=null) ? _fileUpload.modificationDate : null;
		}

		[Bindable(event="propertyChange")]
		public function get size():int
		{
			return (_fileUpload!=null) ? _fileUpload.size : 0;
		}

		[Bindable(event="propertyChange")]
		public function get type():String
		{
			return (_fileUpload!=null) ? _fileUpload.type : '';
		}

		[Bindable(event="propertyChange")]
		public function get bytesPerSecond():int
		{
			return _bytesPerSecond;
		}

		public function get errorID():int
		{
			return _errorID;
		}
		
		public function get errorMessage():String
		{
			return _errorMessage;
		}

		public function get compression():Boolean
		{
			return (_fileUpload is BigFileUpload && BigFileUpload(_fileUpload).compressData);
		}

	}
}