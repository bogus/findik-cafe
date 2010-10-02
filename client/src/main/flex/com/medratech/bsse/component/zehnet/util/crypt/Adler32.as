/**
 * AS3 implementation of the Adler32 checksum algorithm
 * (http://en.wikipedia.org/wiki/Adler-32)
 * 
 * Based on java implementation java.util.zip.Adler32.java
 * retrieved from: http://eckhart.stderr.org/doc/classpath-doc/api/java/util/zip/Adler32-source.html
 * 
 * // Adler32.java - Computes Adler32 data checksum of a data stream
 * // Copyright (C) 1999, 2000, 2001 Free Software Foundation, Inc.
 * // 
 * // This file is part of GNU Classpath.
 * // 
 * // GNU Classpath is free software; you can redistribute it and/or modify
 * // it under the terms of the GNU General Public License as published by
 * // the Free Software Foundation; either version 2, or (at your option)
 * // any later version.
 * 
*/
package com.medratech.bsse.component.zehnet.util.crypt
{
	import flash.utils.ByteArray;
	
	public class Adler32 implements IChecksum
	{
		/** largest prime smaller than 65536 */
		private static const BASE:int = 65521;

		private var checksum:uint;
		
		public function Adler32()
		{
			reset();
		}
		
		/**
		 * Updates the current checksum with the specified array of bytes.
		 * @param buf the byte array to update the checksum with
		 * @param off the start offset of the data
		 * @param len the number of bytes to use for the update. If len==0 the whole ByteArray will used.
		 */
		public function update(buf:ByteArray, off:uint=0, len:uint=0):void
		{
			len = len==0 ? buf.length : len;
			
			//(By Per Bothner)
			var s1:uint = checksum & 0xffff;
			var s2:uint = checksum >> 16;
			
			while (len > 0)
			{
				// We can defer the modulo operation:
				// s1 maximally grows from 65521 to 65521 + 255 * 3800
				 // s2 maximally grows by 3800 * median(s1) = 2090079800 < 2^31
				var n:uint = 3800;
				if (n > len) n = len;
				len -= n;
				
				while (--n >= 0)
				{
					s1 = s1 + (buf[off++] & 0xFF);
					s2 = s2 + s1;
				}
				s1 %= BASE;
				s2 %= BASE;
			}
			
			checksum = (s2 << 16) | s1;
		}

		/**
		 * Returns the current checksum value.
		 * @return the current checksum value
		 */
		public function getValue():uint
		{
			return checksum;// & 0xffffffffL;
		}
		
		/**
		 * Resets the checksum to its initial value.
		 */
		public function reset():void
		{
			checksum = 1;
		}
	}
}