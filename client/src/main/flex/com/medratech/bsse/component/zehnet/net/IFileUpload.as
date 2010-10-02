package com.medratech.bsse.component.zehnet.net
{
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public interface IFileUpload extends IEventDispatcher
	{
		function IFileUpload(reference:FileReference=null):void;
		
		function browse(typeFilter:Array=null):Boolean;
		
		function cancel():void;
		
		function upload(request:URLRequest, overwriteIfExists:Boolean=false):void;
		
		function get data():ByteArray; // ???
		
		function get creationDate():Date;
		
		function get creator():String;
		
		function get modificationDate():Date;
		
		function get name():String;
		
		function get size():Number;
		
		function get type():String;

	}
}