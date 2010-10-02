package com.medratech.bsse.component.zehnet.net
{
	internal class FileUploadResponse
	{
		private var _data:String = '';
		private var _xml:XML;
		
		public function FileUploadResponse(rawData:String)
		{
			parseResponse(rawData);
		}
		
		protected function parseResponse(rawData:String):void
		{
			var response:String;
			
			var e:int = rawData.indexOf("\n");
			if(e<0)
			{
				response = rawData;
			}
			else
			{
				response = rawData.substring(0,e);
				_data = rawData.substring(e+1);
			}
			
			try
			{
				_xml = new XML(response);
			}
			catch(e:Error)
			{
				_xml = new XML();
				return;
			}
			
			
		}

		/**
		 *
		 */
		public function get isError():Boolean
		{
			return (_xml.localName() != 'success');
		}

		/**
		 *
		 */
		public function get errorID():int
		{
			if(isError)
			{
				return int(_xml.attribute("id"));
			}
			return 0;
		}
		
		/**
		 *
		 */
		public function get message():String
		{
			return _xml.text();
		}

		/**
		 * returns the offset attribute of the returned xml packet
		 * if no offset was sepcified -1 is returned
		 */
		public function get fileOffset():int
		{
			var o:String = _xml.attribute("offset").toString();
			
			if(!isError && o!='')
			{
				return int(o);
			}
			return -1;
		}

		/**
		 * returns the checksum attribute of the returned xml packet
		 * if no checksum was sepcified an empty string is returned
		 */
		public function get checksum():String
		{
			var o:String = _xml.attribute("checksum").toString();
			
			if(!isError && o!='')
			{
				return o;
			}
			return '';
		}

		/**
		 * returns the compression attribute of the returned xml packet
		 * if no compression flag was set false is returned
		 */
		public function get compression():Boolean
		{
			var o:String = _xml.attribute("compression").toString();
			
			if(!isError && o=='1')
			{
				return true;
			}
			return false;
		}

		/**
		 * the additional data received with the server response
		 * 
		 * A server response consists of one xml packet with the 
		 * root node <success /> for a successful operation or the
		 * root node <error /> for an unsuccessful operation
		 * 
		 * Additional data can be added from the next line, i.e.:
		 * first line reponse packet: <success offset="30" /> \n <-- newline here
		 * all additional lines are "data"
		 */
		public function get data():String
		{
			return _data;
		}

		public function get xml():XML
		{
			return _xml;
		}

	}
}