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

 
import Utility.PathFinding;
import Utility.GDraw;
import Utility.McLib;
 
// This class describes the behaviour of dragging the mouse pointer over the drawing area.
// Lines will be drawn over the drawing area.
class DrawMouse extends MovieClip {
	private var _d:Number;							// Depth (z-order) MovieClip used to draw lines on
	private var _onEvent:Function;					// Function to invoke when event rises
	private var _format:Object;						// Base format
	private var _isDrawing:Boolean;					// Indicate drawing
	private var _drawOrigin:Array					// Origin of dragging
	
	public function DrawMouse(depth:Number) {
		this.lineStyle(_format._thickness, _format._color, _format._alpha);	// Set line format of lines drawn.
		_isDrawing = false;													// Mouse is not in drawn mode.
	}
	
	// Function starts the drawing mode.
	private function onMouseDown() : Void {
		this.lineStyle(_format._thickness, _format._color, _format._alpha);
		
		// Drawing is only valid over the drawing area and on clean areas.
		if(Grid.activeGrid.hitTest(_root._xmouse, _root._ymouse) && !_root._level0.hitTest(_root._xmouse, _root._ymouse, true)) {
			// If before the mouse was not used for drawing, set the mouse to be drawing (records the origin of drawing).
			if(!_isDrawing) {
				 var currentSquare:Array = Grid.activeGrid.getCurrentSquare(true);
				_drawOrigin = [currentSquare[1], currentSquare[0]];
				_isDrawing = true;
			}
			
			// Move the line to the current mouse position onMouseMove.
			this.moveTo(_root._xmouse, _root._ymouse);
			this.onMouseMove = function() {
				this.lineTo(_root._xmouse, _root._ymouse);
			};
		}
		_onEvent("drawing");
	}
	
	// Function stops drawing mode.
	private function onMouseUp() : Void {
		// Clear the lines drawn by the mouse and stop the drawing.
		this.clear();
		this.onMouseMove = null;
		
		if(_isDrawing) {
			// Snapping
			var _snapMouse:Array = Grid.activeGrid.getCurrentSquare(true);
			
			// Path drawing, drawOrigin in x,y, snapMouse in y,x, pathFind requires y,x
			var p:Array = Utility.PathFinding.pathFind([_drawOrigin[1],_drawOrigin[0]], [_snapMouse[0],_snapMouse[1]]);
			
			// If the path is null, or is a dot then it is invalid
			if (p == null) {
				trace("Line is invalid");
			// Else construct a wire with the path
			} else {
				// Since flip is false, we start with a horizontal, then end with a vertical
				var wires:Array = []; // Pointers to the wires
				// For each wire
				for (var i:Number = 0; i < 2; i++) {
					// Set the end points
					var endPoints:Array = [p[i], p[i+1]];
					var name:String = "wireID" + ++Utility.GDraw.depth;
					// Set up parameters
					var wireParams:Object = {_endPoints:endPoints, _grid: Grid.activeGrid, _direction: i};
					// Create the wire
					wires[i] = Utility.McLib.createWithClass(Wire, _root, name, Utility.GDraw.depth, wireParams);
				}
				// Connect the wires, endPoint indexes are: 0------w0------1 0------w1------1
				for (var j:Number = 0; j < 2; j++) {
					wires[j].connectWire(!j, wires[!j]);
				}
			}
		}
		
		_isDrawing = false;
	}
	

}