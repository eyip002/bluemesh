/*	This file is part of BlueMesh.

    BlueMesh is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BlueMesh is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BlueMesh.  If not, see <http://www.gnu.org/licenses/>.
*/
/*
 * @author	Eugene Yip & Jeffrey Yan
 * @date	20 September 2008
 */

import Utility.GDraw;
import Utility.McLib;

// This class describes a draggable MovieClip representing a BlueMesh entity.
class DragObject extends MovieClip {
	private var _text:String;				// Name of this dragObject (automatically generated).
	private var _font:Object;				// Font format
	private var _onEvent:Function;			// Function to invoke when event rises
	private var _dragOrigin:Array;			// Origin of dragging
	
	private var _image:String;				// Image to overlay

	private var _format:Object;				// Base format
	private var _hoverFormat:Object;		// Hover format
	private var _currentFormat:Object;		// Place holder for current format
	private var _rec:Object;				// DragObject dimensions
	
	private var _depth:Number;				// Depth (z-order)
	private var _panel:Panel;				// Referene to panel that the object sits in
	private var _grid:Grid;					// Reference to grid that the object sits on
	
	private var _isActive:Boolean;			// Selected in edit mode
	private var _value:String;				// Electrical value
	
	// Connections array
	// Referenced by row/column and is relative to the Component, not the grid
	// Each array element is of the format:
	// index = LEFT=0/RIGHT=1/TOP=2/BOTTOM=3
	// val = 1 if connection allowed/not connected, -1 allowed/connected, 0 not allowed/null
	// i.e. connections[y][x] ======> [val, val, val, val]
	public var connections:Array = [];
	private var connectors:Array;
	
	public static var activeObject:DragObject = null;	// The selected component in Edit mode
	
	private static var _topDepth:Number;	//highest depth between all DragObjects


	public function DragObject() {
		focusEnabled = true;					// Allow keyboard focus when selected by the mouse.
		_topDepth = _depth;						// Make the top most depth number equal to this new dragObject
		
		this.attachMovie(_image, _image, 0);	// Overaly with an image
		this[_image]._x = 1;					// Shift it right for a 1px border
		this[_image]._y = 1;					// Shift it down for a 1px border
		this[_image]._width = _rec._w - 1;		// Set the width to dynamically change with the grid
		this[_image]._height = _rec._h - 1;		// Set the height to dynamically change with the grid
		
		this.createConnectors();				// Create the connection sites around this dragObject
		_currentFormat = _format;				// Set current format to base format
		drawLabel();							// Draw the text label
		redraw();								// Draw the MovieClip
	}
	
	// Draw connectors
	private function createConnectors() : Void {
		if (connections.length == 0) {
			return
		}
		connectors = new Array();
		
		var i:Number = 0;
		
		// For each grid square that the dragObject occupies, determine if a connection site is specified.
		// Create it if it is.  Allow for input / output types.
		for (var row:Number = 0; row < _rec._height; row++) {
			for (var column:Number = 0; column < _rec._width; column++) {
				var connect:Array = connections[row][column];
				
				for (var direction:Number = 0; direction < 4; direction++) {
					var format:Object = {_rec: {	_column: column,
													_row: row,
													_d: _grid.d
											   }
										};
					if (connect[direction]) {
						format._name = i;
						format._isInput = (connect[direction] == 1.1);
						format._direction = direction;
						connectors[i++] = Utility.McLib.createWithClass(Connector, this, format.name, ++Utility.GDraw.depth, format);
					}
				}
			}
		}
	}

	// Required to be in mouseOver/mouseUp state for this
	// function to be called
	private function onPress() : Void {
		// Only allow the dragObject to be selected if in Edit mode.
		if (_global.editing) {
			if (activeObject == this) {		// Toggling behaviour
				activeObject = null;
			} else {
				var oldActiveObject:DragObject = activeObject;		// New selection behaviour
				activeObject = this;
				oldActiveObject.onRollOut();
			}
			return;
		}
		
		// Test if the connection site of the dragObject has been clicked.
		for (var i:Number = 0; i < connectors.length; i++) {
			if (connectors[i].hitTest(_root._xmouse, _root._ymouse, true)) {		// Test required due to child MovieClips not getting mouse events.
				connectors[i].onPress();
				return;
			}
		}
		
		this._alpha = 50;
		
		// If not, user must want to drag the dragObject.  Constrain the dragging to within the grid area.
		startDrag(true, _grid.dimensions.x, _grid.dimensions.y, _grid.dimensions.w + _grid.dimensions.x - _rec._w, _grid.dimensions.h + _grid.dimensions.y - _rec._h);
		
		_onEvent("mouseDown");
	}

	// Required to be in mouseDown state for this
	// function to be called
	private function onRelease() : Void {
		// Mouse released in Edit mode
		if (_global.editing) {
			_onEvent("mouseUp");
			return;
		}
		
		// Mouse released on a connection site.
		for (var i:Number = 0; i < connectors.length; i++) {
			if (connectors[i].hitTest(_root._xmouse, _root._ymouse, true)) {
				return;
			}
		}
		
		this._alpha = 100;
		
		// If not, user must have dropped the dragObject.
		stopDrag();
		
		// Get the current grid square that the mouse is over.
		_grid.refreshCurrentSquare();
		var currentSquare:Array = _grid.getCurrentSquare(true);
		
		// Check if the area that the dragObject will be taking up is free.
		var occupiedPoints:Array = [];
		for (var row:Number = 0; row < _rec._height; row++) {
			for (var column:Number = 0; column < _rec._width; column++) {
				occupiedPoints.push([row + currentSquare[0], column + currentSquare[1]]);
			}
		}
		var isClearArea:Boolean = _grid.notOccupied(occupiedPoints, this);
		
		// If the area is free for occupation, give the dragObject the new position.
		if (isClearArea) {
			_rec._x = currentSquare[1]*_grid.d + _grid.dimensions.x;
			_rec._y = currentSquare[0]*_grid.d + _grid.dimensions.y;
			_hoverFormat._rec = _format._rec;
		}
		
		_onEvent("mouseUp", isClearArea);
	}

	// Required to be in mouseOut state for this
	// function to be called
	private function onRollOver() : Void {  
		// Move this dragObject to the top (top most layer).
		this.swapDepths(_topDepth);
		
		// Test if the mouse is over a connection site.
		// A connection site may appear "on" when it should not the mouse moves to fast across the component
		// and cause the onRollOut() call to be missed.
		for (var i:Number = 0; i < connectors.length; i++) {
			if (connectors[i].hitTest(_root._xmouse, _root._ymouse, true)) {
				connectors[i].onRollOver();
				return;
			}
		}
		
		// If not, change button to hover format
		if (_hoverFormat != null) {
			_currentFormat = _hoverFormat;
		}
		
		_onEvent("mouseOver");	// Invoke event Function
	}
   
	// Required to be in mouseUp / mouseOver state for this
	// function to be called
	public function onRollOut() : Void {
		// Return button to original format
		if (!_global.editing || activeObject != this) {
			_currentFormat = _format;
		}
		
		// And rollout all connectors
		for (var i:Number = 0; i < connectors.length; i++) {
			connectors[i].onRollOut();
		}
		_onEvent("mouseOut");
	}
	
	// Setter function for _value variable.  Replace the text label as well.
	public function set value(newValue:String) : Void {
		_value = newValue;
		this["dragLabel"].text = newValue;
		this["dragLabel"].setTextFormat(_font);
	}
	
	// Getting function for _value variable.
	public function get value(newValue:String) : String {
		return _value;
	}
	
	// Getter function for _text variable.
	public function get text() : String {
		return _text;
	}
	
	// Function to remove this dragObject from the Stage.
	public function remove() : Void {
		// Delete all wires connected to each connector
		for (var i:Number = 0; i < this.connectors.length; i++) {
			this.connectors[i].deleteConnectedWires();
		}
		
		_onEvent("delete");
		removeMovieClip(this);
	}
	
	// Function to respond to key presses when in focus
	private function onKeyDown() : Void {
		// If the Delete or Backspace keys are pressed, remove this dragObject.
		if(Key.isDown(Key.BACKSPACE) || Key.isDown(Key.DELETEKEY)) {
			this.remove();
		}
	}
	
	// Function to draw the text label on this dragObject MovieClip
	private function drawLabel() : Void {
		//create label object containing area and location to top, left (for centering)
		var format:Object = {	_rec: {	_x: 0,
										_y: _rec._h/2 - 7,
										_w: _rec._w,
										_h: _rec._h/2 + 7
									  },
								_font: _font
							}
							
		Utility.GDraw.addLabel(this, "dragLabel", _value, 1, format);		//add label to drag object
		this.createTextField("topLeft", 2, 0, 0, 0, 0);		// To suppress bug where the dragObject doesn't get onRelease event
	}
   
	// Function to redraw the fill and borders of this MovieClip
	public function redraw() : Void {
		this.clear();												// Clear this MovieClip for refresh
		Utility.GDraw.formatMovClip(this, _currentFormat, _rec);	// Format button MovieClip
	}

} 