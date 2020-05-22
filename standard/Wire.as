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
 * @author	Jeffrey Yan
 * @date	20 September 2008
 */


import Utility.GDraw;


// Wire class
// The wire object will only exist on the grid points between the 2 routed points, and not including the 2 routed points
class Wire extends MovieClip {
	// New wire variables
	private var _direction:Number;	// 0 for horizontal, 1 for vertical
	private var _endPoints:Array; // An array of endPoints[0] and endPoints[1]
	
	private var _connectedWire:Wire; // The other wire that is connected to this one
	
	// Two arrays corresponding to objects connected to each endpoint, wires can only be connected to connectors or other wires
	private var _connected:Array;
	
	private var _lockConnections:Array = [0,0]; // Set these to 1 to not allow connections to a particular endPoint

	// Global static wire list
	static public var wireList:Array = [];
	
	// Simple variables
	private var _type:String = "wire";
	private var _grid:Grid;
	private var _xOffSet:Number;
	private var _yOffSet:Number;
	
	private var _isSelected:Boolean;
	private var _isHovered:Boolean;

	// Constructor function
	public function Wire() {
		// Initialise simple variables
		this._xOffSet = _grid.dimensions.x + _grid.d/2;
		this._yOffSet = _grid.dimensions.y + _grid.d/2;
		
		// Initialise _connected to be 2 empty arrays
		this._connected = new Array();
		this._connected[0] = new Array();
		this._connected[1] = new Array();
		
		this._isHovered = false;
		this._isSelected = false;
		
		// Push this into the wireList
		Wire.wireList.push(this);
		
		this.redraw();
	}
	
	// Destructor function
	public function deleteWire() {
		// Remove this wire from the _connected list of everything this is connected to
		this.disconnectAll();
		
		// Remove this from the static wireList
		for (var i:Number = 0; i < Wire.wireList.length; i++) {
			if (Wire.wireList[i] == this)
				Wire.wireList.splice(i, 1);
		}
		
		// Remove this from the screen
		removeMovieClip(this);
	}
	
	// Redraw function
	public function redraw() : Void {
		this.clear();		
		if (this._isHovered)
			Utility.GDraw.color = 0x66CCFF;
		else
			Utility.GDraw.color = 0x000000;
			
		Utility.GDraw.thickness = 5;
		
		var shiftEnd:Array = [];
		// Draw the wire shortened at the end of connection to a component, so it doesn't draw over the connector
		if (_connected[0][0] == this._connectedWire)
			shiftEnd = [0,1];
		else if (_connected[1][0] == this._connectedWire)
			shiftEnd = [1,0];
			
		var xPolarity:Number;
		var yPolarity:Number;
		
		if ((_endPoints[0][1] - _endPoints[1][1]) > 0)
			xPolarity = -1;
		else if ((_endPoints[0][1] - _endPoints[1][1]) < 0)
			xPolarity = 1;
		else
			xPolarity = 0;
		
		if ((_endPoints[0][0] - _endPoints[1][0]) > 0)
			yPolarity = 1;
		else if ((_endPoints[0][0] - _endPoints[1][0]) < 0)
			yPolarity = -1;
		else
			yPolarity = 0;
			
		// Draw the wire
		Utility.GDraw.line(this, _endPoints[0][1]*_grid.d + shiftEnd[0]*((_direction == 0) ? 5: 0)*xPolarity + _xOffSet, _endPoints[0][0]*_grid.d + yPolarity*shiftEnd[0]*((_direction == 1) ? 5: 0) + _yOffSet, _endPoints[1][1]*_grid.d + xPolarity*shiftEnd[1]*((_direction == 0) ? 5: 0) + _xOffSet, _endPoints[1][0]*_grid.d + yPolarity*shiftEnd[1]*((_direction == 1) ? 5: 0) + _yOffSet);
	}
	
	// Set one of the end points
	public function setEndPoint(end:Number, newPoint:Array, stop:Boolean) : Void {
		this._endPoints[end] = newPoint;
		// Maintain wire at horizontal or vertical
		if (this._direction == 0)
			this._endPoints[(end+1)%2][0] = newPoint[0];// If horizontal, the ROW of the OTHER end should be the same as this new point
		if (this._direction == 1)
			this._endPoints[(end+1)%2][1] = newPoint[1];  // If vertical, the COLUMN of the OTHER end should be the same as this new point
			
		// Maintain end connections to other wires, through one more level
		if (!stop) {
			// Maintain connections to other wires, without continue at the 'other' endPoint to newPoint
			// For each wire connected at the other end
			for (var i:Number = 0; i < this._connected[(end+1)%2].length; i++) {
				// If this is a wire
				if (this._connected[(end+1)%2][i]._type == "wire") {
					// Change the end connection
					this._connected[(end+1)%2][i].setEndPoint(end, this._endPoints[(end+1)%2], true); // The wire i at the other end of this wire = the end point at the other end of this wire
				}
			}
		}
		
		// redraw
		this.redraw();
	}
	
	// Connect a wire to an endPoint
	public function connectWire(end:Number, w:Wire) : Void {
		if (!_lockConnections[end]) {
			this._connected[end].push(w);
			this._connectedWire = w;
		}
	}
	
	// Connect a connector to an endpoint
	public function connectConnector(end:Number, c:Connector) : Void {
		if (!_lockConnections[end])
			this._connected[end].push(c);
	}
	
	// Remove a wire from the connected list
	public function disconnectWire(end:Number, w:Wire) : Void {
		for (var i:Number = 0; i < this._connected.length; i++) {
			if (this._connected[end][i] == w)
				this._connected[end].splice(i,1);
				return;
		}
	}
	
	// Remove a connector from the connected list
	public function disconnectConnector(end:Number, c:Connector) : Void {
		for (var i:Number = 0; i < this._connected.length; i++) {
			if (this._connected[end][i] == c)
				this._connected[end].splice(i,1);
				return;
		}
	}
	
	// Remove this wire from the _connected list of everything this is connected to
	public function disconnectAll() : Void {
		// For each wire end
		for (var end:Number = 0; end < 2; end++) {
			// For each component connected to that end
			for (var n:Number = 0; n < _connected[end].length; n++) {
				// This object is a wire, so call the removeWire() function of each connected object
				this._connected[end][n].disconnectWire(end, this);
			}
		}
	}
	
	// Mouse listeners
	private function onPress() : Void {
		if (_global.editing) {
			this.flip();
		}
	}
	
	// Flips this wire, and the one connected to it
	private function flip() : Void {
		// Find the end of this wire that it's _connectedWire is connected to
		var end:Number;
		for (var i:Number = 0; i < this._connected.length; i++) {
			for (var j:Number = 0; j < this._connected[i].length; j++) {
				// If this is the end of the connected wire
				if (this._connected[i][j] == this._connectedWire) {
					end = i;
				}
			}
		}
		// Change the mid-point of this wire at the side of 'end'
		this._endPoints[end][this._direction] = this._connectedWire.endPoints[end][this._direction];
		this._endPoints[end][(this._direction+1)%2] = this._endPoints[(end+1)%2][(this._direction+1)%2];
		// Change the mid-point of the other wire
		this._connectedWire.endPoints[(end+1)%2] = this._endPoints[end];
		
		// Flip the directions of both wires
		this._direction = (this._direction+1)%2;
		this._connectedWire.direction = (this._direction + 1)%2
		
		// Set both wires unhovered
		this._isHovered = false;
		this._connectedWire.isHovered = false;
		
		// Redraw both wires
		this.redraw();
		this._connectedWire.redraw();
	}
	
	private function onRollOver() : Void {
		this.useHandCursor = _global.editing;
		this._isHovered = _global.editing;
		this._connectedWire.isHovered = _global.editing;
		this._connectedWire.redraw();
		this.redraw();
	}
	
	private function onRollOut() : Void {
		this._isHovered = false;
		this._connectedWire.isHovered = false;
		this._connectedWire.redraw();
		this.redraw();
	}
	
	private function onRelease() : Void {
		
	}
	
	public function get name() : String {
		return this._name;
	}
	
	public function get connected() : Array {
		return this._connected;
	}
	
	public function get endPoints() : Array {
		return this._endPoints;
	}
	
	public function set isSelected(newValue:Boolean) : Void {
		this._isSelected = newValue;
	}
	
	public function set direction(newValue:Number) : Void {
		this._direction = newValue;
	}
	
	public function set endPoints(newValue:Array) : Void {
		this._endPoints = newValue;
	}
	
	public function set isHovered(newValue:Boolean) : Void {
		this._isHovered = newValue;
	}
	
}
