package com.medratech.bsse.component
{
	import com.medratech.bsse.util.RemoteDataObjectEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Event(name="dataReceived", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	[Event(name="dataInserted", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	[Event(name="dataDeleted", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	[Event(name="dataUpdated", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	[Event(name="versionReceived", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	[Event(name="refreshed", type="com.medratech.bsse.util.RemoteDataObjectEvent")]
	public class RemoteDataArray
	{
		private var remoteObject:RemoteObject;
		private var remoteSource:String;
		
		[Bindable]
		public var remoteData:ArrayCollection = null;
		[Bindable]
		public var remoteReturnObject:Object = null;
		[Bindable]
		public var remoteDestination:String;
		
		public function RemoteDataArray(remoteSource:String, remoteDestination:String)
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
			remoteObject.getVersion.addEventListener(ResultEvent.RESULT,getVersionListener);
			remoteObject.refresh.addEventListener(ResultEvent.RESULT, refreshListener);
		
			this.getObject();
		}
				
		private function faultListener(event:FaultEvent):void {
			Alert.show(event.fault.message);
	    }
	    	    
	    private function updateDataListener(event:ResultEvent):void {
	    	remoteReturnObject = event.result as Object;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.DATA_UPDATED);
			dispatchEvent(eventObj);
	   	}
	   	private function insertDataListener(event:ResultEvent):void {
	   		remoteReturnObject = event.result as Object;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.DATA_INSERTED);
			dispatchEvent(eventObj);
	   	} 
	   	private function deleteDataListener(event:ResultEvent):void {
	   		remoteReturnObject = event.result as Object;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.DATA_DELETED);
			dispatchEvent(eventObj);
   		}
   		private function getDataListener(event:ResultEvent):void {   
			remoteData = event.result as ArrayCollection;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.DATA_RECEIVED);
			dispatchEvent(eventObj);
		}
		private function getVersionListener(event:ResultEvent):void {   
			remoteReturnObject = event.result as Number;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.VERSION_RECEIVED);
			dispatchEvent(eventObj);
		}
		private function refreshListener(event:ResultEvent):void {   
			remoteReturnObject = event.result as Object;
			var eventObj:RemoteDataObjectEvent = new RemoteDataObjectEvent(RemoteDataObjectEvent.VERSION_RECEIVED);
			dispatchEvent(eventObj);
		}
		
		public function updateObject(obj:Object):void {
	        remoteObject.updateData(obj);
	    }
	    
	    public function getObject():void {
	    	remoteObject.getData();
	    }
	    
	    public function getObjectByType(type:int):void {
	    	remoteObject.getData(type);
	    }
	    
	    public function getObjectByObject(obj:Object):void {
	    	remoteObject.getData(obj);
	    }
	    
	    public function remove(obj:Object):void {
	    	remoteObject.deleteData(obj);
	    }
	    
	    public function insert(obj:Object):void {
	    	remoteObject.insertData(obj);
	    }
	    
	    public function getVersion(obj:Object):void {
	    	remoteObject.getVersion(obj.id);
	    }
	    public function refresh(obj:Object):void {
	    	remoteObject.refresh(obj.id);
	    }
	    
	    public function getRemoteObject():RemoteObject {
	    	return remoteObject;
	    }
	}
}