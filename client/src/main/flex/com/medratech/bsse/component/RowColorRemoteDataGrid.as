/*
  Copyright (C) 2009 Burak Oguz (barfan) <findikmail@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
package com.medratech.bsse.component
{
	
	import flash.display.Sprite;

	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	
	public class RowColorRemoteDataGrid extends RemoteDoubleClickDataGrid
	{
		public function RowColorRemoteDataGrid()
		{
			super();
		}
		
		public var rowColorFunction:Function;
    
	    override protected function drawRowBackground(s:Sprite, 
	        rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
	    {
	    	if(rowColorFunction != null && dataProvider != null) 
		  	{
				var item:Object;
				if(dataIndex < dataProvider.length)
				{
				  item = dataProvider[dataIndex];
				}
				
				if(item)
				{
				  color = rowColorFunction(item, rowIndex, dataIndex, color);
				}
		  	}
	      	super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
	    }
	}
}