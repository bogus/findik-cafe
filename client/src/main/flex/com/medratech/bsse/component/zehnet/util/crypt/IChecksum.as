package com.medratech.bsse.component.zehnet.util.crypt
{
	import flash.utils.ByteArray;
	
	public interface IChecksum
	{
		/**
		 * Adds the byte array to the data checksum.
		 * 
		 * @param buf the ByteArray which contains the data
		 * @param off the offset in the ByteArray where the data starts
		 * @param len the length of the data
		 */
		function update(buf:ByteArray, off:uint=0, len:uint=0):void;

		/**
		 * Returns the CRC32 data checksum computed so far.
		 * 
		 * @return the current checksum value
		 */
		function getValue():uint;

		/**
		 * Resets the checksum to its initial value.
		 */
		function reset():void;		
	}
}