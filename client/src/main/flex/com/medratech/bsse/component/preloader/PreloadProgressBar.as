package com.medratech.bsse.component.preloader
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.controls.Text;
	import mx.events.FlexEvent;
	import mx.preloaders.IPreloaderDisplay;
	import mx.resources.ResourceManager;

    public class PreloadProgressBar extends Sprite implements IPreloaderDisplay
    {
        // Settings fiddle with these as you like
        private var _minimumDuration:Number = 2000;   // even if the preloader is done, take this long to "finish"

        // Implementation variables, used to make everything work properly
        private var _IsInitComplete		: Boolean = false;
        private var _timer 				: Timer;			// this is so we can redraw the progress bar
        private var _bytesLoaded 		: uint = 0;
        private var _bytesExpected 		: uint = 1;			// we start at 1 to avoid division by zero errors.
        private var _fractionLoaded 	: Number = 0;		// Will be used for the width of the loading bar
        private var _preloader			: Sprite;
        private var _currentStatus		: String;			// The current stats of the application, downloaded, initilising etc
        
        // Display properties of the loader, these are set in the mx:Application tag
        private var _backgroundColor	: uint = 0x333333;
        private var _stageHeight		: Number = 1;
        private var _stageWidth			: Number = 1;
        private var _loadingBarColour	: uint = 0xFFFFFF;
        
        // Display elements
        private var _loadingBar 		: Rectangle;		// The loading bar that will be drawn
        private var loadingImage 		: flash.display.Loader;
        private var compLabel	 		: TextField;
        private var statusText			: Text;
        
        public function PreloadProgressBar()
        {
            super();
        }
        
        // Called when the appication is ready for the preloading screen
        public function initialize():void
        {
        	this._backgroundColor = 0x333333;
        	drawBackground();
			// Load in your logo or loading image
			loadingImage = new flash.display.Loader();  
			compLabel = new TextField();     
			loadingImage.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler);
			loadingImage.load(new URLRequest("assets/images/minifndk.png")); // This path needs to be relative to your swf on the server, you could use an absolute value if you are unsure
        }
        
        private function loader_completeHandler(event:Event):void
        {        	
        	
        	// Draw the loading image
            addChild(loadingImage);
            loadingImage.width = 187;
            loadingImage.height= 142;
            loadingImage.x = (stageWidth / 2) - (loadingImage.width / 2);
            loadingImage.y = (stageHeight / 2) - (loadingImage.height / 2) - 20; 
            			
			// Draw your loading bar in it's full state - x,y,width,height
            _loadingBar = new Rectangle(loadingImage.x, 
            	loadingImage.y + 160, loadingImage.width, 10);
            
            addChild(compLabel);
            compLabel.width = 332;
            compLabel.x = _loadingBar.x;
            compLabel.y = _loadingBar.y + 20;
            compLabel.text = "Yükleniyor, Lütfen Bekleyiniz\nLoading, Please Wait";
            compLabel.textColor = 0xFFFFFF;
            var format:TextFormat = new TextFormat();
            format.bold = true;
            format.size = 12;
            format.font = "Arial";
            compLabel.setTextFormat(format);
            compLabel.autoSize = TextFieldAutoSize.NONE;
            
            
            // The first change to this var will be Download Complete
            _currentStatus = 'Downloading';	
            
			// Start a timer to redraw your loading elements frequently
            _timer = new Timer(50);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler);
            _timer.start();
        }
        
        // This is called repeatidly untill we are finished loading
        private function draw():void
        {
			graphics.beginFill( _loadingBarColour , 1);
            graphics.drawRect(_loadingBar.x, _loadingBar.y, 
            	_loadingBar.width * _fractionLoaded, _loadingBar.height);
            graphics.endFill();
        }
        
        private function drawBackground():void
        {
			// Draw the background using the background colour (set in the mx:Application MXML tag)
			graphics.beginFill( _backgroundColor, 1);
 			graphics.drawRect( 0, 0, stageWidth, stageHeight);
			graphics.endFill();
        }
        
        
         // This code comes from DownloadProgressBar.  I have modified it to remove some unused event handlers.
        public function set preloader(value:Sprite):void
        {
            _preloader = value;
        
            value.addEventListener(ProgressEvent.PROGRESS, progressHandler);    
            value.addEventListener(Event.COMPLETE, completeHandler);
            
        //    value.addEventListener(RSLEvent.RSL_PROGRESS, rslProgressHandler);
        //    value.addEventListener(RSLEvent.RSL_COMPLETE, rslCompleteHandler);
        //    value.addEventListener(RSLEvent.RSL_ERROR, rslErrorHandler);
            
            value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
            value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
        }

		// Getters and setters for values, most are set via the MXML in the mx:Application tag
        public function set backgroundAlpha(alpha:Number):void{}
        public function get backgroundAlpha():Number { return 1; }
        
        public function set backgroundColor(color:uint):void { _backgroundColor = color; }
        public function get backgroundColor():uint { return _backgroundColor; }
        
        public function set backgroundImage(image:Object):void {}
        public function get backgroundImage():Object { return null; }
        
        public function set backgroundSize(size:String):void {}
        public function get backgroundSize():String { return "auto"; }
        
        public function set stageHeight(height:Number):void { _stageHeight = height; }
        public function get stageHeight():Number { return _stageHeight; }

        public function set stageWidth(width:Number):void { _stageWidth = width; }
        public function get stageWidth():Number { return _stageWidth; }

        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        // Called by the application as the download progresses.
        private function progressHandler(event:ProgressEvent):void
        {
            _bytesLoaded = event.bytesLoaded;
            _bytesExpected = event.bytesTotal;
            _fractionLoaded = Number(_bytesLoaded) / Number(_bytesExpected);
        }
        
        // Called when the download is complete
        private function completeHandler(event:Event):void
        {
        	
        	_currentStatus = 'Download Completed';
        	trace(_currentStatus);
        }
    
        // Called by the application as the initilisation progresses.        
        private function initProgressHandler(event:Event):void
        {
        	if( !_IsInitComplete) // This seems to be called right at the end for some reason, so this stopps it if the app is already complete
        	{
            	_currentStatus = 'Initilising Application';
            	trace(_currentStatus);
         	}
        }
    
        // Called when both download and initialisation are complete    
        private function initCompleteHandler(event:Event):void
        {
        	_currentStatus = 'Initilisation Completed';
        	trace(_currentStatus);
            _IsInitComplete = true;
            
        }

        // Called as often as possible
        private function timerHandler(event:Event):void
        {
            if ( _IsInitComplete && getTimer() > _minimumDuration )
            {    
                // Everything is now ready, so we can tell the application to show the main application
                // NOTE: If you have set a min duration, your application may already have started running
                if(alpha < 0) {
                	_timer.stop();
                	_timer.removeEventListener(TimerEvent.TIMER,timerHandler);
                	dispatchEvent(new Event(Event.COMPLETE));
                }
                else {
                	alpha = alpha - 0.2;
                }
            }
            else
            {
            	// Update the screen with the latest progress
                draw();
            }
        }
    }

}