package com.medratech.bsse.component
{
	import com.medratech.bsse.util.RemoteDataObjectEvent;
	
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Event(name="dataReceived", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	public class RemoteDataObject
	{
		private var remoteObject:RemoteObject;		
		private var remoteSource:String;		
		
		[Bindable]
		public var remoteData:Object = null;
		[Bindable]
		private var remoteDestination:String;
		
		public function RemoteDataObject(remoteSource:String, remoteDestination:String)
		{
			super();
			this.remoteSource = remoteSource;
			this.remoteDestination = remoteDestination;
		}
		
		public function init():void {
		
			remoteObject = new RemoteObject(remoteDestination);
			remoteObject.source = remoteSource;
			remoteObject.showBusyCursor = true;
			remoteObject.addEventListener(FaultEvent.FAULT,faultListener);
			remoteObject.getData.addEventListener(ResultEvent.RESULT,getDataListener);
			remoteObject.insertData.addEventListener(ResultEvent.RESULT,insertDataListener);
			remoteObject.updateData.addEventListener(ResultEvent.RESULT,updateDataListener);
			remoteObject.deleteData.addEventListener(ResultEvent.RESULT,deleteDataListener);
		
			this.getObject();
		}
				
		private function faultListener(event:FaultEvent):void {
			Alert.show(event.fault.message);
	    }
	    	    
	    private function updateDataListener(event:ResultEvent):void {
	    	
	   	}
	   	private function insertDataListener(event:ResultEvent):void {
	   	
	   	} 
	   	private function deleteDataListener(event:ResultEvent):void {
	   	
   		}
   		private function getDataListener(event:ResultEvent):void {   
			remoteData = (event.result as Array)[0] as Object;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.DATA_RECEIVED);
			dispatchEvent(eventObj);
		}
		
		public function updateObject(obj:Object):void {
	        remoteObject.updateData(obj);
	    }
	    
	    public function getObject():void {
	    	remoteObject.getData();
	    }
	    
	    public function remove(obj:Object):void {
	    	remoteObject.deleteData(obj);
	    	remoteObject.getData();
	    }
	    
	    public function insert(obj:Object):void {
	    	remoteObject.insertData(obj);
	    	remoteObject.getData();	    		
	    }
	    
	    public function getRemoteObject():RemoteObject {
	    	return remoteObject;
	    }
	}
}