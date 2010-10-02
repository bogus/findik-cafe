package com.medratech.bsse.component.zehnet.events
{
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import com.medratech.bsse.component.zehnet.net.IFileUpload;
	
	public class FileUploadEvent extends Event
	{
		/**
		 * Event, triggered when the fileCheck request is sent to the server
		 * 
		 * Attention: There is no FILE_CHECK_PROGRESS event
		 */
		public static const FILE_CHECK_OPEN:String 		= "fileCheckOpen";

		/**
		 * Event, triggered when the fileCheck request was answered by the server
		 * AND the fileCheck was successul, i.e. the file does not exist and
		 * can be uploaded to the server.
		 */		
		public static const FILE_CHECK_COMPLETE:String 	= "fileCheckComplete";

		/**
		 * Event, dispatched when a ram loading operation starts.
		 * 
		 * Ramloading is an operation where the file contents are loaded
		 * into the ram of the client machine with calling the "load"
		 * method of the FileReference object (Flash 10).
		 */	
		public static const RAMLOAD_OPEN:String 		= "ramloadOpen";

		/**
		 * Event, dispatched periodically during the ram loading operation.
		 */
		public static const RAMLOAD_PROGRESS:String 	= "ramloadProgress";

		/**
		 * Event, dispatched when the ram loading operation completes.
		 */
		public static const RAMLOAD_COMPLETE:String 	= "ramloadComplete";

		/**
		 * Event, dispatched when an upload operation starts.
		 */	
		public static const UPLOAD_OPEN:String 		= "uploadOpen";

		/**
		 * Event, dispatched periodically during the file upload operation.
		 */
		public static const UPLOAD_PROGRESS:String 	= "uploadProgress";

		/**
		 * Event, dispatched when the file upload operation completes successfully.
		 */
		public static const UPLOAD_COMPLETE:String 	= "uploadComplete";

		/**
		 * Event, dispatched when a checksum calculation operation starts.
		 */	
		public static const CHECKSUM_OPEN:String 		= "checksumOpen";

		/**
		 * Event, dispatched periodically during the checksum calculation.
		 */
		public static const CHECKSUM_PROGRESS:String 	= "checksumProgress";

		/**
		 * Event, dispatched when the checksum calculation completes.
		 */
		public static const CHECKSUM_COMPLETE:String 	= "checksumComplete";	
		
		private var _urlRequest:URLRequest;
		
		private var _bytesLoaded:Number;
		
		private var _bytesTotal:Number;
		
		private var _data:String;
		
		/**
		 * 
		 */
		public function FileUploadEvent(type:String, request:URLRequest, bLoaded:Number=0, bTotal:Number=0, additionalData:String='', bubbles:Boolean = false, cancelable:Boolean = false)
		{
			_urlRequest = request;
			_bytesLoaded = bLoaded;
			_bytesTotal = bTotal;
			_data = additionalData;
			super(type, bubbles, cancelable);
		}

		/**
		 * the target url of the upload request.
		 * Remember with event.target you will receive an IFileUpload object
		 * which can be used to check for fileName, fileSize etc.
		 */			
		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}

		/**
		 * in case of:
		 * a) an UPLOAD_* event, returns the number bytes already uploaded to the server
		 * b) an RAMLOAD_* event, returns the number of bytes already loaded into the ram
		 * c) an CHECKSUM_* event, returns the number bytes already calculated
		 * d) an FILE_CHECK_* event, is not set and returns 0
		 */	
		public function get bytesLoaded():Number
		{
			return _bytesLoaded;
		}

		/**
		 * in case of:
		 * a) an UPLOAD_*, RAMLOAD_*, CHECKSUM_* events, returns the total number of bytes of the file
		 * b) an FILE_CHECK_* event, is not set and returns 0
		 */	
		public function get bytesTotal():Number
		{
			return _bytesTotal;
		}

		/**
		 * <p>returns the additional data retrieved with
		 * a server response.</p>
		 * 
		 * <p>A server response consists of one xml packet with the 
		 * root node &lt;success /&gt; for a successful operation or the
		 * root node &lt;error /&gt for an unsuccessful operation.</p>
		 * 
		 * <p>Additional data can be added from the next line, i.e.:
		 * first line reponse packet: &lt;success offset="30" /&gt \n &lt;-- newline here
		 * all additional lines are "data"</p>
		 */	
		public function get data():String
		{
			return _data;
		}

	}
}