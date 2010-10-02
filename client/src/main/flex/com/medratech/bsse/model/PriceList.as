package com.medratech.bsse.model
{
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.PriceList")]
	public class PriceList extends Model
	{
		public var day:int;
		public var hour:int;
		public var price:Number;
		public var tariff:Tariff;
		
		
		public function PriceList()
		{
		}

	}
}