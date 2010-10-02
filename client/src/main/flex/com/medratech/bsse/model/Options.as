package com.medratech.bsse.model
{
	import flash.utils.ByteArray;
	
	[Bindable]
	[RemoteClass(alias="com.medratech.findik.domain.Options")]
	public class Options extends Model
	{
		
		public var openSessionAutomatically:Boolean;
	    public var recoverPassword:String;
	    public var screenSaverImage:ByteArray;
	    public var banner:ByteArray;	
		
		public function Options()
		{
		}

	}
}