package com.medratech.bsse.util
{
	import flash.events.Event;

	public class RemoteDataInsertedEvent extends Event
	{
		public static const DATA_INSERTED:String = "dataInserted";

		
		public function RemoteDataInsertedEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event {
            return new RemoteDataInsertedEvent(type);
        }

	}
}