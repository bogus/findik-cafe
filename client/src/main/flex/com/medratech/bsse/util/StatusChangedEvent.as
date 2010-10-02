package com.medratech.bsse.util
{
	import flash.events.Event;

	public class StatusChangedEvent extends Event
	{
		public static const STATUS_CHANGED:String = "statusChanged";

		
		public function StatusChangedEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event {
            return new StatusChangedEvent(type);
        }

	}
}