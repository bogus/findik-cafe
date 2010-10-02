package com.medratech.bsse.component
{
	import com.medratech.bsse.util.IPUtil;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.data.Grid;
	import org.alivepdf.data.GridColumn;
	import org.alivepdf.display.Display;
	import org.alivepdf.drawing.Joint;
	import org.alivepdf.fonts.*;
	import org.alivepdf.layout.*;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Download;
	import org.alivepdf.saving.Method;
		
	public class GeneratePDF
	{
		public function GeneratePDF()
		{
		}
		
		private function savePDF(pdf:PDF, pdfName:String):void
		{
			pdf.save(Method.REMOTE, "/mydlp-web-manager/create_pdf.php", Download.ATTACHMENT, pdfName);
		}
		
		public function generateFromIssueDataGrid(dataGrid:DataGrid, pdfName:String):void  
        {
        	var resourceManager:IResourceManager = ResourceManager.getInstance();    
    	    var pdf:PDF = new PDF( Orientation.LANDSCAPE, Unit.MM, Size.A4); 
            pdf.setDisplayMode( Display.DEFAULT, Layout.SINGLE_PAGE );
			pdf.addPage();
		
			var gridColumnDate:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.date'), "date", 30);
		   	var gridColumnRule:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.rule'), "rule", 25);
		   	var gridColumnProtocol:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.protocol'), "protocol", 15);
		   	var gridColumnSource:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.source'), "source", 35);
		   	var gridColumnTarget:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.target'), "target", 35);
		   	var gridColumnAction:GridColumn = new GridColumn("Action", "action", 20);
		   	var gridColumnCategory:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.category'), "category", 40);
		   	var gridColumnStatus:GridColumn = new GridColumn(resourceManager.getString('resources', 'issue.filter.status'), "status", 20);
		   	var gridColumnUser:GridColumn = new GridColumn(resourceManager.getString('resources', 'issue.filter.severity'), "severity", 20);
		   	var gridColumnSeverity:GridColumn = new GridColumn(resourceManager.getString('resources', 'issue.filter.user'), "user", 20);
		   	var columns:Array = new Array ( gridColumnDate, gridColumnRule, gridColumnProtocol, gridColumnSource,
		   		 gridColumnTarget, gridColumnAction, gridColumnCategory, gridColumnStatus, 
		   		 gridColumnUser, gridColumnSeverity);
			
			
			var arr:ArrayCollection = new ArrayCollection();
			var dataProviderArr:Array = dataGrid.dataProvider.toArray();
			
			for(var i:int = 0; i < dataProviderArr.length; i++)
			{
				var obj:Object = new Object();
				obj.date = dataProviderArr[i].date;
				obj.rule = dataProviderArr[i].rule_name + "\n" + dataProviderArr[i].filter_name;
				obj.protocol = dataProviderArr[i].protocol;
				obj.source = IPUtil.Long2IP(dataProviderArr[i].src_ip) + "\n" + dataProviderArr[i].src_user;
				obj.target = dataProviderArr[i].destination;
				obj.action = dataProviderArr[i].action;
				obj.category = dataProviderArr[i].matcher + "\n" + dataProviderArr[i].filename + "\n" + dataProviderArr[i].misc;
				
				if(dataProviderArr[i].status == 0)
					obj.status = resourceManager.getString('resources', 'issue.filter.status.open');
				else if(dataProviderArr[i].status == 1)
					obj.status = resourceManager.getString('resources', 'issue.filter.status.assigned');
				else if(dataProviderArr[i].status == 2)
					obj.status = resourceManager.getString('resources', 'issue.filter.status.fixed');
				else if(dataProviderArr[i].status == 3)
					obj.status = resourceManager.getString('resources', 'issue.filter.status.notfixed');
					
				if(dataProviderArr[i].severity == 0)
					obj.severity = resourceManager.getString('resources', 'issue.filter.severity.default');
				else if(dataProviderArr[i].severity == 1)
					obj.severity = resourceManager.getString('resources', 'issue.filter.severity.high');
				else if(dataProviderArr[i].severity == 2)
					obj.severity = resourceManager.getString('resources', 'issue.filter.severity.normal');
				else if(dataProviderArr[i].severity == 3)
					obj.severity = resourceManager.getString('resources', 'issue.filter.severity.low');
					
				obj.user = dataProviderArr[i].username;
				arr.addItem(obj);
			}
			
			pdf.setCreator("Medratech");
			pdf.textStyle( new RGBColor(0), 1  );
			pdf.setFont ( FontFamily.ARIAL, Style.NORMAL, 8 );
	   		var grid:Grid = new Grid( arr.toArray(), 120, 200, new RGBColor (0x666666), new RGBColor (0xCCCCCC), new RGBColor (0), true, new RGBColor ( 0x0 ),1, Joint.MITER );
			grid.columns = columns;
			
			pdf.addText(new Date().toString(), 10, 20);
			pdf.addGrid(grid, 0, 20, true);
			savePDF(pdf, pdfName);	
		}
		
		public function generateFromLogDataGrid(dataGrid:DataGrid, pdfName:String):void  
        {
        	var resourceManager:IResourceManager = ResourceManager.getInstance();    
    	    var pdf:PDF = new PDF( Orientation.LANDSCAPE, Unit.MM, Size.A4); 
            pdf.setDisplayMode( Display.DEFAULT, Layout.SINGLE_PAGE );
			pdf.addPage();
		
			var gridColumnDate:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.date'), "date", 35);
		   	var gridColumnRule:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.rule'), "rule", 35);
		   	var gridColumnProtocol:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.protocol'), "protocol", 20);
		   	var gridColumnSource:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.source'), "source", 45);
		   	var gridColumnTarget:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.target'), "target", 45);
		   	var gridColumnAction:GridColumn = new GridColumn("Action", "action", 20);
		   	var gridColumnCategory:GridColumn = new GridColumn(resourceManager.getString('resources', 'logs.search.category'), "category", 50);
		   	var columns:Array = new Array ( gridColumnDate, gridColumnRule, gridColumnProtocol, gridColumnSource,
		   		 gridColumnTarget, gridColumnAction, gridColumnCategory);
			
			var arr:ArrayCollection = new ArrayCollection();
			var dataProviderArr:Array = dataGrid.dataProvider.toArray();
			
			for(var i:int = 0; i < dataProviderArr.length; i++)
			{
				var obj:Object = new Object();
				obj.date = dataProviderArr[i].date;
				obj.rule = dataProviderArr[i].rule_name + "\n" + dataProviderArr[i].filter_name;
				obj.protocol = dataProviderArr[i].protocol;
				obj.source = IPUtil.Long2IP(dataProviderArr[i].src_ip) + "\n" + dataProviderArr[i].src_user;
				obj.target = dataProviderArr[i].destination;
				obj.action = dataProviderArr[i].action;
				obj.category = dataProviderArr[i].matcher + "\n" + dataProviderArr[i].filename + "\n" + dataProviderArr[i].misc;
				arr.addItem(obj);
			}
			
			pdf.setCreator("Medratech");
			pdf.textStyle( new RGBColor(0), 1  );
			pdf.setFont ( FontFamily.ARIAL, Style.NORMAL, 8 );
	   		var grid:Grid = new Grid( arr.toArray(), 120, 200, new RGBColor (0x666666), new RGBColor (0xCCCCCC), new RGBColor (0), true, new RGBColor ( 0x0 ),1, Joint.MITER );
			grid.columns = columns;
			
			pdf.addText(new Date().toString(), 10, 20);
			pdf.addGrid(grid, 0, 20, true);	
			savePDF(pdf, pdfName);
		}
	}
}