package com.medratech.bsse.util
{
	import flash.events.Event;

	public class ItemDeleteEvent extends Event
	{
		public static const BEFORE_DELETE:String = "beforeDelete";
		public var componentId:String = "";
		public var items:Array = null;
		
		public function ItemDeleteEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event {
            return new ItemDeleteEvent(type);
        }

	}
}