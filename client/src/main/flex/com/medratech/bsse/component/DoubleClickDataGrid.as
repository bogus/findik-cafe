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
	
	import flash.events.MouseEvent;
	
	import mx.controls.DataGrid;

	public class DoubleClickDataGrid extends DataGrid {
	
		public function DoubleClickDataGrid() {
			super();
			doubleClickEnabled = true;
		}
		
		public function get listRendererArray():Array {
			return listItems;
		}
		
		override protected function mouseDoubleClickHandler(event:MouseEvent):void {
			super.mouseDoubleClickHandler(event);
			super.mouseDownHandler(event);
			super.mouseUpHandler(event);
		}
		
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			var saved:Boolean = editable;
			editable = false;
			super.mouseUpHandler(event);
			editable = saved;
		}
	}
}
