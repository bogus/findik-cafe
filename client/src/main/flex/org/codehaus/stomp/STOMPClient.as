/**
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
 /*
 	Version 0.1 : R Jewson (rjewson at gmail dot com).  First release, only for reciept of messages.
 	Version 0.3 : Derek Wischusen (dwischus at flexonrails dot com).  
 */

package org.codehaus.stomp {
	
	import flash.net.XMLSocket;
	import flash.events.*;
    import flash.utils.Timer;
	import flash.display.*;
	import org.codehaus.stomp.frame.*;
	import org.codehaus.stomp.event.*;
	import org.codehaus.stomp.headers.*;
	
	public class STOMPClient extends Sprite {
  
  		static public const SHORT_INT : int = 1000;
		static public const MEDIUM_INT : int = 5000;
		static public const LONG_INT : int = 10000;
		static public const NEWLINE : String = "\n";
		static public const BODY_START : String = "\n\n";
		static public const NULL_BYTE : String = "\u0000";
  
    	private var socket : XMLSocket = new XMLSocket();
 		
		private var server : String;
		private var port : int;
		private var connectHeaders : ConnectHeaders;
		
		public var autoReconnect : Boolean = true;
		
  		private var socketConnected : Boolean   = false;
		private var protocolPending : Boolean   = false;
		private var protocolConnected : Boolean = false;
		private var expectDisconnect : Boolean  = false;
		
		public var sessionID : String;
		public var setInterval : int = 0;
		private var subscriptions : Array = new Array();
		
		private var timer : Timer; 
		private var connectTimer : Timer;
		
		public var connectTime : Date = null;
		public var disconnectTime : Date = null;
		public var connectAttempts : int = 0;

		public var errorMessages : Array = new Array();
		
  		public function STOMPClient(  ) 
  		{
			socket.addEventListener( Event.CONNECT, onConnect );
	  		socket.addEventListener( Event.CLOSE, onClose );
      		socket.addEventListener( DataEvent.DATA, onData );
			socket.addEventListener( IOErrorEvent.IO_ERROR, onError );

		}
	
		public function doConnectTimer( event:TimerEvent ):void 
		{
			doConnect();
		}
	
		public function connect( server : String = "localhost", port : int = 61613, connectHeaders : ConnectHeaders = null) : void 
		{
			this.server = server;
			this.port = port
			this.connectHeaders = connectHeaders;
			doConnect();
		}
		
		private function doConnect() : void 
		{
			if (socketConnected==true)
				return;
			socket.connect( server, int(port) );
			socketConnected = false;
			protocolConnected = false;
			protocolPending = true;
			expectDisconnect = false;
		}
	
		private function doDisconnect() : void 
		{
			expectDisconnect = true;
			socket.close();
		}
	
 	   	private function onConnect( event:Event ) : void 
 	   	{
			if (connectTimer!=null) {
				connectTimer.stop();
			}
			var h : Object = connectHeaders ? connectHeaders.getHeaders() : {}; 
			transmit("CONNECT", connectHeaders);
			socketConnected = true;
    	}
	
		private function onClose( event:Event ) : void 
		{
			socketConnected = false;
			protocolConnected = false;
			protocolPending = false;
			disconnectTime = new Date();

			if ((expectDisconnect==false)&&(autoReconnect==true)) 
			{
				connectTimer = new Timer(MEDIUM_INT);
				connectTimer.addEventListener(TimerEvent.TIMER, doConnectTimer);
				connectTimer.start();
			}
		}

		private function onError( event:Event ) : void 
		{
			var now:Date = new Date();
			if (!socket.connected) {
				socketConnected = false;
				protocolConnected = false;
				protocolPending = false;
				disconnectTime = now;
			}
			errorMessages.push(now + " " + event.type);
		}
		
		public function subscribe(destination : String, headers : SubscribeHeaders = null) : void 
		{

			var h : Object = headers ? headers.getHeaders() : null;
				
			if (socketConnected)
			{
				if (!h)
					h = {};
				
				h['destination'] = destination;
				transmit("SUBSCRIBE", h);
			}
			
			subscriptions.push({destination: destination, headers: headers, connected: socketConnected});

		}
		
		public function send (destination : String, message : String, headers : SendHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['destination'] = destination;
			transmit("SEND", h,  message);
		}
		
		public function begin (transaction : String, headers : BeginHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['transaction'] = transaction;
			transmit("BEGIN", h);
		}

		public function commit (transaction : String, headers : CommitHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['transaction'] = transaction;
			transmit("COMMIT", h);
		}
		
		public function ack (messageID : String, headers : AckHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['message-id'] = messageID;
			transmit("ACK", h);
		}
		
		public function abort (transaction : String, headers : AbortHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['transaction'] = transaction;
			transmit("ABORT", h);
		}		
		
		public function unsubscribe (destination : String, headers : UnsubscribeHeaders = null) : void
		{
			var h : Object = headers ? headers.getHeaders() : {};
				
			h['destination'] = destination;
			transmit("UNSUBSCRIBE", h);
		}
		
		public function disconnect () : void
		{
			transmit("DISCONNECT", {});
		}	
		
		private function transmit (command : String, headers : Object, body : String = "") : void
		{
			var transmission : String;
			transmission = command + NEWLINE;
			
			for (var header: String in headers)
				transmission += header + ":" + headers[header] + NEWLINE;
			
			transmission += "content-length:" + body.length + NEWLINE;		       
	        transmission += "content-type:text/plain; charset=UTF-8";	        
	        transmission += BODY_START;
			transmission += body;
	        transmission += NULL_BYTE;
	        
	        socket.send( transmission );
		
		}
		
		private function processSubscriptions() : void 
		{
			for each (var sub : Object in subscriptions)
			{
				if (sub['connected'] == false)
					this.subscribe(sub['destination'], SubscribeHeaders(sub['headers']));
			}
		}
	
	    private function onData(event : DataEvent):void {
			
			var frame : String = event.data;
			var frameStart : int = frame.search(/\S/);
			var commandEnd : int = frame.indexOf(NEWLINE, frameStart);
			var bodyStart : int = frame.indexOf(BODY_START);
			
			var command : String = frame.slice(frameStart, commandEnd);
			var body : String = frame.slice(bodyStart + 2);
			var headers : Object = new Object();
			
			var headerString : String = frame.substring(commandEnd+1, bodyStart);
			var headerValuePairs : Array = headerString.split(NEWLINE);
			
			for each (var pair : String in headerValuePairs) 
			{
				var separator : int = pair.indexOf(":");
				headers[pair.substring(0, separator)] = pair.substring(separator+1);
			}
			
			switch (command) 
			{
				
				case "CONNECTED":
					protocolConnected = true;
					protocolPending = false;
					expectDisconnect = false;
					connectTime = new Date();
					sessionID = headers['session'];
					processSubscriptions();
					dispatchEvent(new ConnectedEvent(ConnectedEvent.CONNECTED));				
				break;
				
				case "MESSAGE":
					var messageEvent : MessageEvent = new MessageEvent(MessageEvent.MESSAGE);
					messageEvent.message = new MessageFrame(body, headers);
					dispatchEvent(messageEvent);
				break;
				
				case "RECEIPT":
					var receiptEvent : ReceiptEvent = new ReceiptEvent(ReceiptEvent.RECIEPT);
					receiptEvent.receiptID = headers['receipt-id'];
					dispatchEvent(receiptEvent);
				break;
				
				case "ERROR":
					var errorEvent : STOMPErrorEvent = new STOMPErrorEvent(STOMPErrorEvent.ERROR);
					errorEvent.error = new ErrorFrame(body, headers);
					dispatchEvent(errorEvent);					
				break;
				
				default:
					throw new Error("UNKNOWN STOMP FRAME");
				break;
				
			}
		}
  	}
}
