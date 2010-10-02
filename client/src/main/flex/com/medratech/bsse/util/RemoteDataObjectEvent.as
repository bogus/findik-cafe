package com.medratech.bsse.util
{
	import flash.events.Event;

	public class RemoteDataObjectEvent extends Event
	{
		public static const DATA_RECEIVED:String = "dataReceived";
		public static const DATA_INSERTED:String = "dataInserted";
		public static const DATA_UPDATED:String = "dataUpdated";
		public static const DATA_DELETED:String = "dataDeleted";
		public static const VERSION_RECEIVED:String = "versionReceived";
		public static const REFRESHED:String = "refreshed";

		
		public function RemoteDataObjectEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event {
            return new RemoteDataObjectEvent(type);
        }

	}
}