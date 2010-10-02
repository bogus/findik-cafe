package com.medratech.bsse.util
{
	 import flash.external.ExternalInterface;

     public class URLUtil    {

        protected static const WINDOW_OPEN_FUNCTION : String = "window.open";

        public static function openWindow(url : String, window : String = "_blank", features : String = "") : void {
            ExternalInterface.call(WINDOW_OPEN_FUNCTION, url, window, features, true);            
        }
        
        public static function getBrowserName():String {
        	var method:XML = <![CDATA[
			     function( ){ 
			         return { appName: navigator.appName, version:navigator.appVersion};}
			    ]]>
			
			var o:Object = ExternalInterface.call( method );
			return o.appName;
        }

    }
}