////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2008 Andrei Ionescu
//  http://www.flexer.info/
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use, misuse,
//  copy, modify, merge, publish, distribute, love, hate, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to no conditions whatsoever.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE. DON'T SUE ME FOR SOMETHING DUMB
//  YOU DO. 
//
//  PLEASE DO NOT DELETE THIS NOTICE.
//
////////////////////////////////////////////////////////////////////////////////

package com.medratech.bsse.component
{
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.managers.CursorManager;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class ResizableCanvas extends Canvas
	{
		// right edge of the canvas
		private var _rightEdge:Button;
		// bottom edge of the canvas
		private var _bottomEdge:Button;
		// the cursor id
		private var _currentCursorId:int;
		// true if the horizontal drag started
		private var _dragHStarted:Boolean;
		// true if the vertical drag started
		private var _dragVStarted:Boolean;
		// the position before starting to drag
		private var _dragStartHPosition:int;
		// the position before starting to drag
		private var _dragStartVPosition:int;
		// last width of our canvas before starting to drag
		private var _dragLastWidth:int;
		// last height of our canvas before starting to drag
		private var _dragLastHeight:int;
		// is resizable horizontally
		private var _isResizableHorizontally:Boolean;
		// is resizable vertically
		private var _isResizableVertically:Boolean;
		// cursor image (horizontal)
		[Embed("/assets/images/rcanvas/img/h_resize.gif")]
		private var _hResizeCursor:Class;
		// cursor image (vertical)
		[Embed("/assets/images/rcanvas/img/v_resize.gif")]
		private var _vResizeCursor:Class;
		
		// Constructor
		public function ResizableCanvas(hResizable:Boolean = true, vResizable:Boolean = false):void
		{
			super();
			// initialization
			_dragHStarted = false;
			_dragVStarted = false;
			_dragStartHPosition = 0;
			_dragStartVPosition = 0;
			_currentCursorId = -1;
			// by default our canvas is resizable horizontally
			horizontalResizable = hResizable;
			verticalResizable = vResizable;
		}
		
		// setter to enable/disable the horizontal resize functionality
		public function set horizontalResizable(value:Boolean):void
		{
			// if the value is changed
			if (value != _isResizableHorizontally)
			{
				if (value)
				{
					// horizontalResizable = true

					// we add the right edge which is a button
					_rightEdge = new Button();
					// no label
					_rightEdge.label = "";
					// no tooltip
					_rightEdge.tabEnabled = false;
					_rightEdge.toolTip = null;
					_rightEdge.setStyle("right", 0);
					_rightEdge.setStyle("verticalCenter",0);
					_rightEdge.percentHeight = 95;
					_rightEdge.width = 9;
					// set its style
					// in this style we set the skin to not show anything
					_rightEdge.styleName = "canvasRightEdge";
					
					// used to display the resize icon
					_rightEdge.addEventListener(MouseEvent.MOUSE_OVER, handleHResizeOver, false, 0 ,true);
					// used to display the resize icon
					_rightEdge.addEventListener(MouseEvent.MOUSE_MOVE, handleHResizeOver, false, 0 ,true);
					// used to hide the resize icon
					_rightEdge.addEventListener(MouseEvent.MOUSE_OUT, handleResizeOut, false, 0 ,true);
					// used to start the drag
					// we save the initial position and width
					_rightEdge.addEventListener(MouseEvent.MOUSE_DOWN, handleHDragStart, false, 0 ,true);
					// used for real rezise and other important stuff
					_rightEdge.addEventListener(Event.ENTER_FRAME, handleHDragMove, false, 0 ,true);
					// used to stop the drag - mouse up on the edge
					_rightEdge.addEventListener(MouseEvent.MOUSE_UP, handleDragStop, false, 0 ,true);
					
					addChild(_rightEdge);
					
				} else {
					// horizontalResizable = false
					
					// we check if the events are created and we remove them
					if (_rightEdge.hasEventListener(MouseEvent.MOUSE_OVER))
						_rightEdge.removeEventListener(MouseEvent.MOUSE_OVER, handleHResizeOver);
					if (_rightEdge.hasEventListener(MouseEvent.MOUSE_OUT))
						_rightEdge.removeEventListener(MouseEvent.MOUSE_OUT, handleResizeOut);
					if (_rightEdge.hasEventListener(MouseEvent.MOUSE_DOWN))
						_rightEdge.removeEventListener(MouseEvent.MOUSE_DOWN, handleHDragStart);
					if (_rightEdge.hasEventListener(MouseEvent.MOUSE_UP))
						_rightEdge.removeEventListener(MouseEvent.MOUSE_UP, handleDragStop);
					if (_rightEdge.hasEventListener(Event.ENTER_FRAME))
						_rightEdge.removeEventListener(Event.ENTER_FRAME, handleHDragMove);
					// we check if the stage if created and if it has the event listener
					if (stage != null && stage.hasEventListener(MouseEvent.MOUSE_UP))
						stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStop);
					// we remove the edge
					removeChild(_rightEdge);
				}
				// set the resizable value
				// used to see if the value is changed
				_isResizableHorizontally = value;
			}
		}
		
		// setter to enable/disable the vertical resize functionality
		public function set verticalResizable(value:Boolean):void
		{
			// if the value is changed
			if (value != _isResizableVertically)
			{
				if (value)
				{
					// verticalResizable = true

					// we add the right edge which is a button
					_bottomEdge = new Button();
					// no label
					_bottomEdge.label = "";
					// no tooltip
					_bottomEdge.tabEnabled = false;
					_bottomEdge.toolTip = null;
					_bottomEdge.setStyle("bottom", 0);
					_bottomEdge.setStyle("horizontalCenter",0);
					_bottomEdge.percentWidth = 95;
					_bottomEdge.height = 9;
					// set its style
					// in this style we set the skin to not show anything
					_bottomEdge.styleName = "canvasBottomEdge";
					/*
					// used to display the resize icon
					_bottomEdge.addEventListener(MouseEvent.MOUSE_OVER, handleVResizeOver, false, 0 ,true);
					// used to display the resize icon
					_bottomEdge.addEventListener(MouseEvent.MOUSE_MOVE, handleVResizeOver, false, 0 ,true);
					// used to hide the resize icon
					_bottomEdge.addEventListener(MouseEvent.MOUSE_OUT, handleResizeOut, false, 0 ,true);
					// used to start the drag
					// we save the initial position and width
					_bottomEdge.addEventListener(MouseEvent.MOUSE_DOWN, handleVDragStart, false, 0 ,true);
					// used for real rezise and other important stuff
					_bottomEdge.addEventListener(Event.ENTER_FRAME, handleVDragMove, false, 0 ,true);
					// used to stop the drag - mouse up on the edge
					_bottomEdge.addEventListener(MouseEvent.MOUSE_UP, handleDragStop, false, 0 ,true);
					
					addChild(_bottomEdge);
					*/
				} else {
					// verticalResizable = false
					
					// we check if the events are created and we remove them
					if (_bottomEdge.hasEventListener(MouseEvent.MOUSE_OVER))
						_bottomEdge.removeEventListener(MouseEvent.MOUSE_OVER, handleVResizeOver);
					if (_bottomEdge.hasEventListener(MouseEvent.MOUSE_OUT))
						_bottomEdge.removeEventListener(MouseEvent.MOUSE_OUT, handleResizeOut);
					if (_bottomEdge.hasEventListener(MouseEvent.MOUSE_DOWN))
						_bottomEdge.removeEventListener(MouseEvent.MOUSE_DOWN, handleVDragStart);
					if (_bottomEdge.hasEventListener(MouseEvent.MOUSE_UP))
						_bottomEdge.removeEventListener(MouseEvent.MOUSE_UP, handleDragStop);
					if (_bottomEdge.hasEventListener(Event.ENTER_FRAME))
						_bottomEdge.removeEventListener(Event.ENTER_FRAME, handleVDragMove);
					// we check if the stage if created and if it has the event listener
					if (stage != null && stage.hasEventListener(MouseEvent.MOUSE_UP))
						stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStop);
					// we remove the edge
					removeChild(_bottomEdge);
				}
				// set the resizable value
				// used to see if the value is changed
				_isResizableHorizontally = value;
			}
		}
		
		// event handler to show the resize cursor
		private function handleHResizeOver(event:MouseEvent):void
		{
			// check if we already have the resize cursor set
			if (_currentCursorId == -1)
				_currentCursorId = CursorManager.setCursor(_hResizeCursor,2,-10);
		}
		
		// event handler to start the drag
		private function handleHDragStart(event:MouseEvent):void
		{			
			_dragHStarted = true;
			// we save the initial position and width
			_dragStartHPosition = stage.mouseX;
			_dragLastWidth = width;		
		}

		// event handler for real rezise and other important stuff
		private function handleHDragMove(event:Event):void
		{
			// we put the edge always on the top of the other children
			if (getChildIndex(_rightEdge) < numChildren-1)
				setChildIndex(_rightEdge,numChildren-1);
			// we add the event to stop the drag also on the stage
			// we cannot add this event in set resizable because the
			// stage is not created because set resizable is done at
			// constructor time and stage is set after adding our
			// canvas to the application
			if (stage != null && !stage.hasEventListener(MouseEvent.MOUSE_UP))
				stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStop, false, 0 ,true);
			// we resize our canvas only if drag started
			if (_dragHStarted)
			{
				// get the amount of movement
				// difference between the current mouse x position relative 
				// to the stage and the saved position at mouse down event
				var movement:int = (stage.mouseX - _dragStartHPosition);
				// if the canvas is positioned relative to the center
				// the width will be changed in both left and right directions
				// so we will double the movement
				if (getStyle("horizontalCenter") != undefined)
				{
					movement *= 2;
				}
				// if we move to the left
				if (movement <= 0)
				{
					// check not to pass the minimum width
					if (minWidth < _dragLastWidth + movement)
						width = _dragLastWidth + movement;
					else
						width = minWidth;
				} else {
					// check not to pass the maximum width
					if (maxWidth > _dragLastWidth + movement)
						width = _dragLastWidth + movement;
					else
						width = maxWidth;
				}
			}
		}

		// event handler to show the resize cursor
		private function handleVResizeOver(event:MouseEvent):void
		{
			// check if we already have the resize cursor set
			if (_currentCursorId == -1)
				_currentCursorId = CursorManager.setCursor(_vResizeCursor,2,-10);
		}
		
		// event handler to start the drag
		private function handleVDragStart(event:MouseEvent):void
		{
			_dragVStarted = true;
			// we save the initial position and width
			_dragStartVPosition = stage.mouseY;
			_dragLastHeight = height;
		}

		// event handler for real rezise and other important stuff
		private function handleVDragMove(event:Event):void
		{
			// we put the edge always on the top of the other children 
			// but bellow the right edge
			if (getChildIndex(_bottomEdge) < numChildren-2)
				setChildIndex(_bottomEdge,numChildren-2);
			// we add the event to stop the drag also on the stage
			// we cannot add this event in set resizable because the
			// stage is not created because set resizable is done at
			// constructor time and stage is set after adding our
			// canvas to the application
			if (stage != null && !stage.hasEventListener(MouseEvent.MOUSE_UP))
				stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStop, false, 0 ,true);
			// we resize our canvas only if drag started
			if (_dragVStarted)
			{
				// get the amount of movement
				// difference between the current mouse x position relative 
				// to the stage and the saved position at mouse down event
				var movement:int = (stage.mouseY - _dragStartVPosition);
				// if the canvas is positioned relative to the center
				// the width will be changed in both left and right directions
				// so we will double the movement
				if (getStyle("verticalCenter") != undefined)
				{
					movement *= 2;
				}
				// if we move to the left
				if (movement <= 0)
				{
					// check not to pass the minimum width
					if (minHeight < _dragLastHeight + movement)
						height = _dragLastHeight + movement;
					else
						height = minHeight;
				} else {
					// check not to pass the maximum width
					if (maxHeight > _dragLastHeight + movement)
						height = _dragLastHeight + movement;
					else
						height = maxHeight;
				}
			}
		}

		// event handler to hide the resize cursor
		private function handleResizeOut(event:MouseEvent):void
		{
			if (!_dragHStarted && !_dragVStarted) {
				CursorManager.removeCursor(_currentCursorId);
				_currentCursorId = -1;
			}
		}
		
		// event handler to stop the drag
		private function handleDragStop(event:MouseEvent):void
		{
			_dragHStarted = false;
			_dragVStarted = false;
			CursorManager.removeCursor(_currentCursorId);
			_currentCursorId = -1;
		}
		

	}
}