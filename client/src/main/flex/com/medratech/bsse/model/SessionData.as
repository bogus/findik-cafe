package com.medratech.bsse.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.SessionData")]
	public class SessionData extends Model
	{
		
		public var time:Number;
		public var operation:int;
		public var data:String;
		public var computer:CafeItem;
		public var noncomputer:NonComputer;	
		
		public function SessionData()
		{
		}

	}
}