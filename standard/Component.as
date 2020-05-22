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
 

// This class describes circuit components as an extension of DragObject.
class Component extends DragObject {	
	private var _type:String;				// Component type.
	
	public var topLeftGridPoint:Array = [];	// Grid square that the top left corner of the component is on.
		
	function Component() {
		topLeftGridPoint = [(_rec._y - _grid.dimensions.y)/_grid.d, (_rec._x - _grid.dimensions.x)/_grid.d];
		occupyGrid();		// Set the grid squares, the component will be on top of, to be occupied.
		
		return;
	}
	
	// Function that will be called every time the component gets a mouse event.
	private function _onEvent (state:String, isClearArea:Boolean) : Void {
		switch(state) {
			case("mouseDown"):	break;
			case("mouseUp"):	if (isClearArea) {
									releaseGrid();
									occupyGrid();
								}	
								super.redraw();
								Selection.setFocus(this);
								break;
			case("mouseOver"):	_global.infoBox.setText(_type + ":\n" + _value);
								break;
			case("mouseOut"):	_global.infoBox.setText("");
								break;
			
			case("delete"):		releaseGrid();
								break;
								
			default:			break;
		}
		super.redraw();
	}


	// This function should be called whenever the global variable topLeftGridPoint is changed
	// This function will then re-occupy the grid with the new points, and disconnect all connections
	private function occupyGrid() : Void {
		for (var i:Number  = 0; i < _rec._height; i++) {
			for (var j:Number = 0; j < _rec._width; j++) {
				_grid.occupiedGrid[topLeftGridPoint[0] + i][topLeftGridPoint[1] + j] = this;
			}
		}
		// Occupy the grid with the connectors
		for (var k:Number = 0; k < this.connectors.length; k++) {
			// Occupy the grid
			
			// Call the connectors change function
			this.connectors[k].updateConnections();
		}
	}
	
	private function releaseGrid() : Void {
		for (var i:Number  = 0; i < _rec._height; i++) {
			for (var j:Number = 0; j < _rec._width; j++) {
				_grid.occupiedGrid[topLeftGridPoint[0] + i][topLeftGridPoint[1] + j] = null;
				
				// Disconnect all connections on this grid point
				for (var k:Number = 0; k < 4; k++) {
					// If it is allowed and connected, then the value will be -1
					if (connections[i][j][k] < 0)
						connections[i][j][k] = 1;
				}
			}
		}
		topLeftGridPoint = _grid.getCurrentSquare(true);
	}
	
	// Getter function for _type variable
	public function get type() : String {
		return this._type;
	}
	
	// Getter function for the name of this component
	public function get text() : String {
		return this._text;
	}
	
} 