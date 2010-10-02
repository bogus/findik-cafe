package com.medratech.bsse.component.zehnet.events
{
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import com.medratech.bsse.component.zehnet.net.IFileUpload;

	/**
	 * <p>As there can be several errors whil uploading a file,
	 * FileUpload errors are handled with this single event class
	 * and not with a seperate class for every error.
	 * </p>
	 * 
	 * The FileUpload errors are (like the other events) on a general level grouped 
	 * into different FileUpload actions:
	 * <ul>
	 * <li>FILE_CHECK_ERROR</li>
	 * <li>FILE_RAMLOAD_ERROR</li>
	 * <li>FILE_CHECKSUM_ERROR</li>
	 * <li>FILE_UPLOAD_ERROR</li>
	 * </ul>
	 * 
	 * <p>You can register event listeners for errors of one of these groups.
	 * If an error occurs the error event will be dispatched and further
	 * progressing will be stopped.</p>
	 * 
	 * <p>Each of these general FileUpload actions can have several different errors.
	 * For example within a FileCheck operation the server can return the error
	 * that the file already exists, or the server can return an error that
	 * the file size exceeds the maximum.</p>
	 * 
	 * <p>To handle these errors specifically, each error is assigned an error id and
	 * an error message.</p>
	 * 
	 * <p>So you register an event listener: e.g. 
	 * <code>fileupload.addEventListener(FileUploadErrorEvent.FILE_CHECK_ERROR,onFileCheckError);</code>
	 * </p>
	 * 
	 * and add an error event handling method:
	 * 
	 * <pre>
	 * function onFileCheckError(event:FileUploadErrorEvent)
	 * {
	 * 		// to check for specific errors check for its ids
	 * 		switch(event.errorID)
	 * 		{
	 * 			case(410): // file already exists
	 * 				// do your actions
	 * 				break;
	 * 		}
	 * }
	 * </pre>
	 */
	public class FileUploadErrorEvent extends Event
	{
		/**
		 * Event, triggered when the fileCheck fails
		 */
		public static const FILE_CHECK_ERROR:String 		= "fileCheckError";
		/**
		 * Event, triggered when the operation to load a selected file into the client's ram fails.
		 */
		public static const FILE_RAMLOAD_ERROR:String 		= "fileRamloadError";
		/**
		 * Event, triggered when the calculation of the file's checksum fails
		 */
		public static const FILE_CHECKSUM_ERROR:String 		= "fileChecksumError";
		/**
		 * Event, triggered when the upload operation fails
		 */
		public static const FILE_UPLOAD_ERROR:String 		= "fileUploadError";
		
		
		/**
		 * specific error ids sent by the server, mostly for debugging purpose.
		 * The ID_FILE_EXISTS error can be used to call FileUpload.upload again
		 * but with the overwriteIfExists flag set to overwrite the existing file.
		 * This is exactly what the overwriteFile method of this class does
		 */
		public static const ID_FILE_EXISTS:int = 410;
		
		public static const ID_FILE_EXCEEDS_MAX:int = 420;
		
		public static const ID_FILE_OPEN_FAILED:int = 510;
		
		public static const ID_FILE_SEEK_FAILED:int = 515;
		
		public static const ID_FILE_WRITE_FAILED:int = 520;
		
		public static const ID_FILE_TRUNCATE_FAILED:int = 525;
		
		public static const ID_FILE_HEADER_FAILED:int = 530;
		
		public static const ID_FILE_CLOSE_FAILED:int = 540;
		
		public static const ID_FILE_RENAME_FAILED:int = 550;
		
		public static const ID_FILE_DELETE_FAILED:int = 555;
		
		
		private var _urlRequest:URLRequest;
		
		private var _errorID:int;
		
		private var _errorMessage:String;
		
		/**
		 * constructor
		 */
		public function FileUploadErrorEvent(type:String, request:URLRequest, errId:int=0, errMsg:String='unknown error', bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_urlRequest = request;
			_errorID = errId;
			_errorMessage = errMsg;
			super(type, bubbles, cancelable);			
		}

		/**
		 * the target url of the upload request.
		 * 
		 * Remember with event.target you will receive an IFileUpload object
		 * which can be used to check for fileName, fileSize etc.
		 */			
		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}

		/**
		 * returns the errorID
		 */	
		public function get errorID():int
		{
			return _errorID;
		}

		/**
		 * returns the errorMessage
		 */
		public function get errorMessage():String
		{
			return _errorMessage;
		}

		/**
		 * if error is FILE_CHECK_ERROR && ID_FILE_EXISTS you can use this function
		 * to upload the file and overwrite the one existing on the server
		 */		
		public function overwriteFile():void
		{
			var fileUpload:IFileUpload = target as IFileUpload;
			
			if(type == FILE_CHECK_ERROR && errorID == ID_FILE_EXISTS)
			{
				fileUpload.upload(_urlRequest, true); // overwrite flag set
			}
		}

	}
}