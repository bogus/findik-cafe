package com.medratech.bsse.model
{
	import com.medratech.bsse.util.StatusChangedEvent;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.CafeItem")]
	[Event(name="statusChanged", type="com.medratech.bsse.util.StatusChangedEvent")]
	public class CafeItem extends Model
	{
		public var name:String;
		public var type:int;
		public var generatedId:String;
	    public var IP:String;
	    public var hostname:String;
	    public var tariff:Tariff;
	    public var sessionData:ArrayCollection;
	    public var status:int;
	    public var startTime:Number;
	    public var endTime:Number;
	    public var bill:Number;
	    public var hasOpenRequest:Boolean;
		
		public function CafeItem()
		{
		}

	}
}