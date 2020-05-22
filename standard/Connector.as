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
import Utility.Netlist;
import Utility.PathFinding;

class Connector extends MovieClip{
	private var _size:Number = 9;
	
	private var _name:String;
	private var _direction:Number; // Relative direction to the component
	private var _isInput:Boolean;
	private var _relativePos:Array = []; // Relative position to the reference point of the component, usually the topLeftPoint
	private var _connected:Array; // Pointers to any wire object connectors that this is connected to
	
	private var _format:Object = {	_border: 0,
									_fillType: "linear",
									_alphas: [100],
									_colors: [0xff0000],
									_ratios: [0],
									_matrix: {	matrixType:"box",
												x: 0, 
												y: 0,
												w: 5,
												h: 5,
												r: 0.5*Math.PI
											 }
								 };
	private var _rec:Object;
	private var _isSelected:Boolean;
	private var _isHovered:Boolean;
	
	public static var connectorList:Array = [];
	
	// Should only have indexes 0 and 1
	public static var activeConnector:Array = [];
	
	public function Connector() {
		_rec._w = _size;
		_rec._h = _size;
		
		_isSelected = false;
		_isHovered = false;
		
		calculatePosition();
		
		// _connected should be an array of 2 arrays
		this._connected = new Array();
		this._connected[0] = new Array();
		this._connected[1] = new Array();
		
		// Push this into the connectorList array
		Connector.connectorList.push(this);
		
		redraw();
	}
	
	// Destructor function
	public function deleteConnector() {
		// Remove this connector from everything this is connected to
		this.disconnectAll();
		// Remove this from the static connector list
		for (var i:Number = 0; i < Connector.connectorList.length; i++) {
			if (Connector.connectorList[i] == this)
				Connector.connectorList.splice(i, 1);
		}
	}
	
	private function calculatePosition() : Void {
		var myDirections:Array = ["left", "right", "top", "bottom"];
		// Calculate position for screen drawing, and set up _relativePos
		switch(_direction) {
			// left
			case(0):	_rec._x = -_size/2 + _rec._column*_rec._d - _rec._d/2;
						_rec._y = _rec._d/2 - _size/2 + _rec._row*_rec._d;
						_relativePos = [_rec._row, _rec._column-1];
						break;
			
			// right
			case(1):	_rec._x = (_rec._column + 1)*_rec._d + _rec._d/2 -_size/2;
						_rec._y = _rec._d / 2 - _size/2 + _rec._row*_rec._d;
						_relativePos = [_rec._row, _rec._column+1];
						break;
						
			// top
			case(2):	_rec._x = _rec._d / 2 - _size/2 + _rec._column*_rec._d;
						_rec._y = -_size/2 + _rec._row*_rec._d - _rec._d/2;
						_relativePos = [_rec._row-1, _rec._column];
						break;
			
			// bottom
			case(3):	_rec._x = -_size/2 + _rec._d / 2 + _rec._column*_rec._d;
						_rec._y = (_rec._row + 1)*_rec._d + _rec._d/2 -_size/2;
						_relativePos = [_rec._row+1, _rec._column];
						break;
			
			default:	break;
		}
		trace("Creating a connector at point [" + [_rec._row, _rec._column] + "] on the " + myDirections[_direction] + " hence _relativePos =  [" + _relativePos + "]");
	}
	
	public function onPress() : Void {
		_isSelected = !_isSelected;
		if (_isSelected) {
			// If this connector is being selected, push it into the activeConnector array
			activeConnector.push(this);
			// If there are more than 2 active connectors, remove the oldest one
			if (activeConnector.length > 2)
				activeConnector.splice(0,1);
			
			// If the activeConnector array has fewer than 2 items, return
			if (activeConnector[0] == null || activeConnector[1] == null)
				return;
			
			// ========== Else if 2 connectors are now active make a connection unconditionally: ==========
			var connectorGridPoints:Array = [];
			// For each connector, get it's gridPoint on the grid
			for (var i:Number = 0; i < 2; i++) {
				trace(activeConnector[i]._parent.topLeftGridPoint);
				connectorGridPoints[i] = [activeConnector[i]._parent.topLeftGridPoint[0] + activeConnector[i]._relativePos[0], activeConnector[i]._parent.topLeftGridPoint[1] + activeConnector[i]._relativePos[1]];
			}
			
			// Create a wire connection between these grid points
			// Path drawing, drawOrigin in x,y, snapMouse in y,x, pathFind requires y,x
			var p:Array = Utility.PathFinding.pathFind(connectorGridPoints[0], connectorGridPoints[1]);
			
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
					var wireParams:Object = {_endPoints:endPoints, _grid: activeConnector[i]._parent._grid, _direction:i};
					// Create the wire
					wires[i] = Utility.McLib.createWithClass(Wire, _root, name, Utility.GDraw.depth, wireParams);
				}
				
				// Do the connections [c0] 0------w0------1 0------w1------1 [c1]
				for (var j:Number = 0; j < 2; j++) {
					// Connect the wires at their midpoint
					wires[j].connectWire((j+1)%2, wires[(j+1)%2]);
					// Connect the wire ends to the connectors, and connectors to the wire ends
					activeConnector[j].connectWire(j, wires[j]); // Connect w0's end 0 to activeConnector[0], and w1's end 1 to activeConnector[1]
					// Redraw the wire
					wires[j].redraw();
				}
				resetActiveConnectors();
			}
		} else {
			// For each activeConnector
			for (var i:Number = 0; i < 2; i++) {
				if (activeConnector[i] == this)
					activeConnector.splice(i,1);
			}
		}
	}
	
	// Connect a wire's particular end to this connector's _connected[end] array
	public function connectWire(end:Number, wire:Wire) : Void {
		// Add this wire to this connector's _connected[end] list
		this._connected[end].push(wire);
		// Add this connector to the wire's _connected[end] list
		wire.connectConnector(end, this);
	}
	
	// Remove a wire from this _connected list
	public function disconnectWire(end:Number, w:Wire) : Void {
		for (var i:Number = 0; i < this._connected.length; i++) {
			if (this._connected[end][i] == w)
				this._connected[end].splice(i,1);
				return;
		}
	}
	
	
	// Delete all wires connected to this connector
	public function deleteConnectedWires() : Void {
		// For each end
		for (var end:Number = 0; end < 2; end++) {
			// While there are still wires (when wires are deleted they are removed from this._connected also)
			while (this._connected[end].length > 0) {
				// Delete the any wires connected to the other end of the wire connected to this connector
				this._connected[end][0].connected[(end+1)%2][0].deleteWire();
				
				// Delete the wire directly connected to this connector
				this._connected[end][0].deleteWire();
			}
		}
	}
	
	// The DragObject has moved, updated all points
	public function updateConnections() : Void {
		// Get the new top left point of this DragObject
		var topLeftGridPoint:Array = this._parent.topLeftGridPoint;
		// Go through the _connected list at both ends, notifying wires that they need updating
		for (var end:Number = 0; end < 2; end++) {
			// For each connected wire
			//trace("Connector at " + this._relativePos + " has this._connected[end].length = " + this._connected[end].length);
			for (var i:Number = 0; i < this._connected[end].length; i++)
			{
				// Calculate the point of this connector
				var point:Array = [topLeftGridPoint[0] + this._relativePos[0], topLeftGridPoint[1] + this._relativePos[1]];
				
				// Set it's end point to match this one
				this._connected[end][i].setEndPoint(end, point);
			}
		}
	}
	
	public function onRollOver() : Void {  
		_isHovered = true;
		
		redraw();
	}
   
	public function onRollOut() : Void {
		_isHovered = false;
		
		redraw();
	}
	
	private function redraw() : Void {
		this.clear();
		(!_isSelected && !_isHovered)
			? this._alpha = 40
			: this._alpha = 100;
			
		(_isInput)
			? _format._colors = [0xff0000]
			: _format._colors = [0x00ff00];
			
		Utility.GDraw.formatMovClip(this, _format, _rec);
	}
	
	// Remove this connector from the _connected list of everything this is connected to
	public function disconnectAll() : Void {
		// For each end
		for (var end:Number = 0; end < 2; end++) {
			// For each wire connected to that end
			for (var n:Number = 0; n < _connected[end].length; n++) {
				// This object is a connector, so call the disconnectConnector() function of each connected object
				this._connected[end][n].disconnectConnector(end, this);
			}
		}
	}
	
	// Reset the static active connectors
	public function resetActiveConnectors() : Void {
		// Set both connectors to be unselected and delete them from the activeConnector array
		// For each active connector
		for (var connectorNum:Number = 0; connectorNum < 2; connectorNum++) {
			// Set it to not selected
			activeConnector[connectorNum]._isSelected = false;
			// Redraw it
			activeConnector[connectorNum].redraw();
			// Set the activeConnector variable to be null
			activeConnector[connectorNum] = null;
		}
	}
	
	// Get the name of this connector
	public function get name() : String {
		return this._parent._text + "_" +  this._name;
	}
	
	// Get the connections array
	public function get connected() : Array {
		return this._connected;
	}
	
	// Get the isInput variable
	public function get isInput() : Boolean {
		return this._isInput;
	}
}
