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
import flash.events.Event;

public class SuperPanelEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	static public const MAXIMIZE:String =     "maximize";
	static public const MINIMIZE:String =     "minimize";
	static public const RESTORE:String =      "restore";
	static public const DRAG_START:String =   "dragStart";
	static public const DRAG:String =         "drag";
	static public const DRAG_END:String =     "dragEnd";
	static public const RESIZE_START:String = "resizeStart";
	static public const RESIZE_END:String =   "resizeEnd";
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function SuperPanelEvent(type:String, 
									cancelable:Boolean=false,
									bubbles:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
}
}