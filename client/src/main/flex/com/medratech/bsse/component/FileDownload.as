package com.medratech.bsse.component
{
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;

    public class FileDownload extends UIComponent {

        private var fr:FileReference;
        // Define reference to the download ProgressBar component.
        [Bindable]
        public var pb:ProgressBar;
        // Define reference to the "Cancel" button which will immediately stop the download in progress.
        [Bindable]
        public var btn:Button;
        
        [Bindable]
        public var grid:RemoteDoubleClickDataGrid = null;

        public function FileDownload() {
			fr = new FileReference();
        }

        private function initDownload():void {			
            
            fr.removeEventListener(Event.OPEN, openUploadHandler);
            fr.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.removeEventListener(Event.COMPLETE, completeUploadHandler);
            fr.removeEventListener(Event.SELECT, selectUploadHandler);
            btn.removeEventListener(MouseEvent.CLICK,cancelUpload);
            
            fr.addEventListener(Event.OPEN, openDownloadHandler);
            fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.addEventListener(Event.COMPLETE, completeDownloadHandler);
            btn.addEventListener(MouseEvent.CLICK,cancelDownload);
        }
        
        private function initUpload():void {
			
            fr.removeEventListener(Event.OPEN, openDownloadHandler);
            fr.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.removeEventListener(Event.COMPLETE, completeDownloadHandler);
            btn.removeEventListener(MouseEvent.CLICK,cancelDownload);
            
            fr.addEventListener(Event.OPEN, openUploadHandler);
            fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.addEventListener(Event.COMPLETE, completeUploadHandler);
            fr.addEventListener(Event.SELECT, selectUploadHandler);
            btn.addEventListener(MouseEvent.CLICK,cancelUpload);
        }

		/**
		 * Download events
		 */ 
        private function openDownloadHandler(event:Event):void {
            pb.label = resourceManager.getString('resources', 'backup.downloading')+" %3%%";
            btn.enabled = true;
        }
        
        private function completeDownloadHandler(event:Event):void {
            pb.label = resourceManager.getString('resources', 'backup.downloadingcomplete');
            pb.setProgress(0, 100);
            btn.enabled = false;
        }
        
        public function startDownload(downloadUrl:String, fileName:String = null):void {
        	initDownload();
            var request:URLRequest = new URLRequest();
            request.url = downloadUrl;
            fr.download(request, fileName);
        }
        
        public function cancelDownload():void {
            fr.cancel();
            pb.label = resourceManager.getString('resources', 'backup.downloadingcancelled');
            btn.enabled = false;
        }
        
        /**
        * Upload Events
        */
        private function openUploadHandler(event:Event):void {
            pb.label = resourceManager.getString('resources', 'backup.uploading')+" %3%%";
            btn.enabled = true;
        }
        
        
		private function addFiles(s:String):void {
		  //if not IE:
		  
		}
        
        public function startUpload():void {
        	initUpload();
            try
			{
				fr.browse();			
			}
			catch (error:Error)
			{
				Alert.show(error.message);
			    trace("Unable to browse for files.");
			}
        }
         
        private function selectUploadHandler(event:Event):void {
            var request:URLRequest = new URLRequest("/mydlp-web-manager/bckprstr.php?import=1");
		    try
		    {
		        fr.upload(request);
		    }
		    catch (error:Error)
		    {
		    	Alert.show(error.message);
		        trace("Unable to upload file.");
		    }
        }
        
        private function completeUploadHandler(event:Event):void {
            pb.label = resourceManager.getString('resources', 'backup.uploadingcomplete');
            pb.setProgress(0, 100);
            btn.enabled = false;
            if(grid != null)
            	grid.getGridData();
        }
        
        public function cancelUpload():void {
            fr.cancel();
            pb.label = resourceManager.getString('resources', 'backup.uploadingcancelled');
            btn.enabled = false;
        }      
        
		/**
		 * Progress Bar
		 */ 
        private function progressHandler(event:ProgressEvent):void {
            pb.setProgress(event.bytesLoaded, event.bytesTotal);
        }
    }
}