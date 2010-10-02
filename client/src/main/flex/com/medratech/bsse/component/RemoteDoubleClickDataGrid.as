package com.medratech.bsse.component
{
	import com.medratech.bsse.util.RemoteDataInsertedEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.controls.Alert;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.DataGridEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Event(name="dataInserted", type="com.medratech.bsse.util.RemoteDataInsertedEvent")]
	public class RemoteDoubleClickDataGrid extends DoubleClickDataGrid
	{
		protected var remoteObject:RemoteObject;
		
		[Bindable]
		public var remoteDestination:String;
		[Bindable]
		public var remoteSource:String;
		
		[Bindable]
		public var remoteSpecificObject:RemoteObject;
		
		[Bindable]
		public var containsPopup:Boolean = false;
		[Bindable]
		public var popup:Object;
		
		protected var selectedCategoryId:int = 0;
		
		public function RemoteDoubleClickDataGrid()
		{
			super();
		}
		
		public function init():void {
		
			remoteObject = new RemoteObject(remoteDestination);
			//remoteObject.source = remoteSource;
			remoteObject.showBusyCursor = true;
			remoteObject.addEventListener(FaultEvent.FAULT,faultListener);
			remoteObject.getData.addEventListener(ResultEvent.RESULT,getDataListener);
			remoteObject.insertData.addEventListener(ResultEvent.RESULT,insertDataListener);
			remoteObject.updateData.addEventListener(ResultEvent.RESULT,updateDataListener);
			remoteObject.deleteData.addEventListener(ResultEvent.RESULT,deleteDataListener);
			remoteObject.search.addEventListener(ResultEvent.RESULT,getDataListener);
		
			this.addEventListener(DataGridEvent.ITEM_EDIT_END,updateGrid);	
			
			this.allowMultipleSelection = true;
			this.getGridData();
		}
		
		override public function get listRendererArray():Array {
			return listItems;
		}
				
		private function faultListener(event:FaultEvent):void {
			Alert.show(event.fault.message);
			if(containsPopup) {
				PopUpManager.removePopUp(popup as Alert);
				containsPopup = false;
			}
	    }
	    	    
	    private function updateDataListener(event:ResultEvent):void {	}
	    
	   	private function insertDataListener(event:ResultEvent):void {
	   		var eventObj:RemoteDataInsertedEvent = new RemoteDataInsertedEvent(RemoteDataInsertedEvent.DATA_INSERTED);
			dispatchEvent(eventObj);
	   	} 
	   	
	   	private function deleteDataListener(event:ResultEvent):void {	}
	   	
   		private function getDataListener(event:ResultEvent):void {
   			try {
				dataProvider = event.result as ArrayCollection;
   			} catch(e:Error) {
   				Alert.show(e.message);
   				dataProvider = new ArrayCollection();
   			}
		}
		
		public function updateGrid(event:DataGridEvent):void {
	        if (event.dataField == "id") {
	             event.preventDefault();
	             return;
	        }
	        var dataGrid:DoubleClickDataGrid = event.target as DoubleClickDataGrid;
	        var col:DataGridColumn = dataGrid.columns[event.columnIndex];
	        var newValue:String = dataGrid.itemEditorInstance[col.editorDataField];
	        var val:Object = event.itemRenderer.data as Object	
	        if (newValue == val[event.dataField])
	           	return;
	        val[event.dataField] = newValue;
	        remoteObject.updateData(val);
	    }
	    
	    public function getGridData():void {
	    	if(selectedCategoryId == 0)
				remoteObject.getData();
			else
				remoteObject.getData(selectedCategoryId);			
	    }
	    
	    public function remove(arr:Array):void {
	    	var i:int = 0;
	    	var j:int = 0;
	    	for(;i < arr.length ;i++) {
	    		if(arr[i].hasOwnProperty("id")) {
	    			var o:Object = new Object();
	    			o.id = arr[i].id;
	    			remoteObject.deleteData(o);	
	    		} else {
	    			remoteObject.deleteData(arr[i]);	
	    		}
	    		var cursor:IViewCursor = dataProvider.createCursor();
	    		for(j = 0; !cursor.afterLast; j++) {
	    			if(cursor.current.id == arr[i].id) {
	    				dataProvider.removeItemAt(j);
	    			} 
	    			cursor.moveNext();
	    		}
	    	}
	    	if(selectedCategoryId == 0)
				remoteObject.getData();
			else
				remoteObject.getData(selectedCategoryId);
	    }
	    
	    public function insert(arr:Array):void {
	    	var i:int = 0;
	    	for(;i < arr.length ;i++) {  
	    		remoteObject.insertData(arr[i]);
	    	}
	    	
	    	if(selectedCategoryId == 0)
				remoteObject.getData();
			else
				remoteObject.getData(selectedCategoryId);
	    }
	    
	    public function updateData(obj:Object):void {
	    	remoteObject.updateData(obj);
	    	if(selectedCategoryId == 0)
				remoteObject.getData();
			else
				remoteObject.getData(selectedCategoryId);
	    }
	    
	    public function getRemoteObject():RemoteObject {
	    	return remoteObject;
	    }
	    
	    public function search(obj:Object):void {
	    	remoteObject.search(obj);
	    }
	    
	    public function changeSelectedCategory(selectedCategoryId:int):void {
   			this.selectedCategoryId = selectedCategoryId;
   			remoteObject.getData(selectedCategoryId);
   		}
	}
}