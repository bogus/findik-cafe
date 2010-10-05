package com.medratech.bsse.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.SessionData")]
	public class SessionData extends Model
	{
		
		public var eventEndTime:Number;
		public var eventStartTime:Number;
		public var eventData:String;
		public var cafeItemId:Number;
		
		public function SessionData()
		{
		}

	}
}