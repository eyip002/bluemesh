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

class Grid extends MovieClip {
	public var dimensions:Object = {x:null, y:null, w:null, h:null};
	public var d:Number; // Grid spacing
	public var name:String;
	
	private var counter:Number;
	private var mainGridArea:MovieClip;
	private var snapMouse:Array;
	private var currentSquare:Array;
	
	private var selectedSquare:MovieClip;

	
	// Occupied grid uses a row, colum indexing style
	// null if free, 1 if occupied
	// Change to non-static later to be able to accomodate for multiple grids
	// occupiedGrid[row][column]
	public var occupiedGrid:Array = [];
	
	// ==================== These 2 arrays should be filled in by the individual Components ====================
	// An array that gives the Component object of each occupied square of occupiedGrid, for ease of referencing
	public static var componentGrid:Array = [];
	// A list of components, this list can be used to iterate through the components and their attributes
	// Components can then be referenced by using their id in the form: _root["panel1"][id] where id is a direct Component reference
	public static var componentList:Array = [];

	public static var activeGrid:Grid = null;
	
	public function Grid() {
		// Create the drawing area
		name = "gridArea" + ++Utility.GDraw.depth;
		
		this.useHandCursor = false;
		_x = dimensions.x;
		_y = dimensions.y;
		
		// Initialise the mouse move counter
		counter = 0;
		currentSquare = [null, null];
		
		this.drawInitialGrid();
		
		// Initialise the occupiedGrid of Component
		this.initOccupiedGrid();
		this.drawSelSquare(0, 0);
		
		activeGrid = this;
	}
	
	/*
	* Functions related to maintaining the occupancy of the grid, these include functions to
	* initialise the occupiedGrid array to all nulls, get the currently highlighted square on the grid
	* and to return the occupancy status of a set of specified grid points
	*/

	// Initialises the array of the occupied grid, we can access arbitrary points in a 1D array, but not 2D
	public function initOccupiedGrid() : Void {
		var rows:Number = dimensions.h/d;
		
		for (var i:Number = 0; i < rows; i++) {
			occupiedGrid[i] = new Array();
		}
	}
	
	public function getSquare(gridPoint:Array) : Array {
		return [gridPoint[0] % d, gridPoint[1] % d];
	}
	
	// Returns the currently selected grid point [row, column]
	// asGridPoint == true: not actual screen coordinates
	// asGridPoint == false: top-left location of square on screen
	public function getCurrentSquare(asGridPoint:Boolean) : Array {
		if (currentSquare[0] == null) {
			return currentSquare;
		}
		if (asGridPoint) {
			return [currentSquare[1]/d, currentSquare[0]/d];
		} else {
			return [currentSquare[1], currentSquare[0]];
		}
	}
	
	// Takes in an array of points and returns whether all of these points are not occupied in the grid
	// Points should be of the form [y, x] denoting row/column indexing
	public function notOccupied(points:Array, object:DragObject) : Boolean {
		for (var i:Number = 0; i < points.length; i++) {
			// If the point is occupied return false
			if (occupiedGrid[points[i][0]][points[i][1]] != null && occupiedGrid[points[i][0]][points[i][1]] != object) {
				return false;
			}
		}
		// Else if all the points are not occupied, i.e. they are null then return true
		return true;
	}
	
	// Checks whether a particular connection point is free, references a grid square, then a side of that square
	public function checkConnectionPoint(gridPoint:Array, direction:Number) : Boolean {
		// First check which component is situated at that point
		var component:Component = occupiedGrid[gridPoint[0]][gridPoint[1]];
		
		if (component == null) {
			trace("There is no component at this location");
			return false;
		}
		
		// Convert the grid relative point reference to an object relative grid reference
		var topLeftGridPoint:Array = component.topLeftGridPoint;
		var objectPoint:Array = [topLeftGridPoint[0] - gridPoint[0], topLeftGridPoint[1] - gridPoint[1]];
		
		// Check if a connection is available at that point for the particular direction, and if so check if it is free
		for (var i:Number = 0; i < 4; i++) {
			// If there is an allowed connection at this direction, and that it is free
			if (component.connections[objectPoint[0]][objectPoint[1]][direction] == 1) {
					return true;
				}
		}
		// Otherwise return false if any of these conditions is false;
		return false;
	}
	
	// Connect the point of a component at a certain direction, should only be called if checkConnectionPoint returned true
	public function connectPoint(gridPoint:Array, direction:Number) : Void {
		// First check which component is situated at that point
		var component:Component = occupiedGrid[gridPoint[0]][gridPoint[1]];
		
		// Convert the grid relative point reference to an object relative grid reference
		var topLeftGridPoint:Array = component.topLeftGridPoint;
		var objectPoint:Array = [topLeftGridPoint[0] - gridPoint[0], topLeftGridPoint[1] - gridPoint[1]];
		
		// Set the connection for this direction to be 1
		component.connections[objectPoint[0]][objectPoint[1]][direction] *= -1;
	}
	
	
	/*
	* Functions related to drawing the grid, these include functions to draw squares,
	* to highlight squares that the mouse is over and to dehighlight squares
	*/
	
	// Fill up the grid area with normal unhighlighted squares
	private function drawInitialGrid() : Void {
		var columns:Number = dimensions.w/d;
		var rows:Number = dimensions.h/d;
		
		// Draw the grid
		for (var i:Number = 0; i < columns; i++) {
			for (var j:Number = 0; j < rows; j++) {
				drawNormSquare(i*d, j*d, d, d);
			}
		}	
	}
	
	// Mouse Move listener
	private function onMouseMove() : Void {
		// Reduce calculations by a factor of 10 for each onMouseMove() call
		if ((++counter % 10) != 0)
			return;
			
		refreshCurrentSquare();
	}
	
	// Mouse Move listener
	public function refreshCurrentSquare() : Void {
		// Highlight the proper square
		if (isInDimensions([this._xmouse, this._ymouse])) {
			// Current location of the snapped mouse
			var snappedXMouse:Number = this._xmouse - this._xmouse % d;
			var snappedYMouse:Number = this._ymouse - this._ymouse % d;
			
			snapMouse = [snappedXMouse, snappedYMouse];
			
			if (currentSquare != snapMouse) {
				selectedSquare._visible = true;
				selectedSquare._x = snapMouse[0];
				selectedSquare._y = snapMouse[1];
				currentSquare = snapMouse;
			}
		} else {
			selectedSquare._visible = false;
			currentSquare = [null, null];
		}
	}
	
	
	// Checks if the mouse is within the grid dimensions
	private function isInDimensions(pos:Array) : Boolean {
		return (pos[0] > -1 && pos[0] < dimensions.w   &&   pos[1] > -1 && pos[1] < dimensions.h)
	}
	
	// Draw a normal square
	private function drawNormSquare(x:Number, y:Number) : Void {
		Utility.GDraw.color = 0xcccccc;
		Utility.GDraw.thickness = 1;
		
		Utility.GDraw.nonFilledRect(this, x, y, d, d);
	}
	
	// Draw a movieclip for a selected square
	// Function should only be called once
	private function drawSelSquare(x:Number, y:Number) : Void {
		selectedSquare = this.createEmptyMovieClip("selectedSquare", ++Utility.GDraw.depth);
		selectedSquare._visible = false;
		
		Utility.GDraw.color = 0x3399FF;
		Utility.GDraw.thickness = 1;
		
		Utility.GDraw.nonFilledRect(selectedSquare, x, y, d, d);
	}	

}