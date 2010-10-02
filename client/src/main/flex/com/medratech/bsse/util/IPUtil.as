package com.medratech.bsse.util
{
	public class IPUtil
	{
		public static function IP2Long(ip:String):Number {
		        var long:Number = 0.0;
		        var num_arr:Array = ip.split(".");
		        
		        for (var i:Number = 0; i < 4; i++)
		        {
		                long *= 256.0;
		                long += parseInt(num_arr[i]);
		        }
		        
		        return long;
		}
		
		public static function Long2IP(long:Number):String {
		        var num_arr:Array = new Array(0, 0, 0, 0);
		        var c:Number = 16777216;
		        
		        for (var i:Number = 0; i < 4; i++)
		        {
		                var k:Number = int(long / c);
		                long -= c * k;
		                num_arr[i] = k;
		                c /= 256;
		        }
		        
		        return num_arr.join(".");
		}

	}
}