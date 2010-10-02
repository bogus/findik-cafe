package com.medratech.bsse.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.Tariff")]
	public class Tariff extends Model
	{
		
		public var name:String;
		public var prices:ArrayCollection;
		public var minBillTime:Number;
		public var cafeItem:ArrayCollection;
		
		
		public function Tariff()
		{
		}

	}
}