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

// Path finding class
class Utility.PathFinding {
	// Need to set the size of the grid, i.e. width/grid spacing etc.
	public static var mapH:Number;
	public static var mapW:Number;
	
	// Pathfinding control variables
	public static var ignoreWiresAtEnds:Boolean = true; // If this is set to to true, the pathfinding algorithm will ignore wires

	// The current open list
	public static var openList:Array = [];
	
	// Contains the current calculated statuses of all squares calculations are done on
	public static var statusList:Array = [];
	
	private static function PathFinding() {	};
	
	// Simple path finder, simple draws a wire with a 90 degree turn, even if it goes through components, returns 3 points
	static public function pathFind(startPoint:Array, endPoint:Array, flip:Boolean) : Array {
		// Don't allow point connectors
		if (startPoint == endPoint)
			return null;
		
		var midPoint:Array = midPoint(startPoint, endPoint, flip);	
		
		var path:Array = [];
		path.push(startPoint);
		path.push(midPoint);
		path.push(endPoint);
		
		return path;
	}
	
	// Calculate mid-point between any 2 points, gives a preference to a starting horizontal, ending vertical
	// flip will give preference to a starting vertical, ending horizontal
	static public function midPoint(startPoint:Array, endPoint:Array, flip:Boolean) : Array {
		if (flip)
			return [endPoint[0], startPoint[1]];
		else
			return [startPoint[0], endPoint[1]];
	}
	
	// Shortest path around components finder
	static public function pathFind2(startY:Number, startX:Number, endY:Number, endX:Number) : Array {		
		
		trace([startY, startX] + " to " + [endY, endX]);
		
		// New arrays
		for (var i:Number =0 ; i < mapH; i++) {
			statusList[i] = [];
		}
		
		openSquare(startY, startX, undefined, 0);
		
		while (openList.length > 0 && !isClosed(endY, endX)) {
			var i:Number = nearerSquare();
			// Gets the current nearest square points
			// Initially will return the first square
			var nowY:Number = openList[i][0];
			var nowX:Number = openList[i][1];

			// Closes current square
			closeSquare(nowY, nowX);
			// Opens all nearby squares, ONLY if:
			for (var j:Number = nowY - 1; j < nowY + 2; j++) {
				for (var k:Number = nowX - 1; k < nowX + 2; k++) {
					if (j >= 0 && j < mapH && k >= 0 && k < mapW && !(j == nowY && k == nowX) && (j == nowY || k == nowX)) {
					// j and k within boundaries, and they're not equal to the current middle point
						if (true) { //(Grid.activeGrid.occupiedGrid[j][k] == null || (ignoreWiresAtEnds && isWire(j,k) && ((j == startY && k == startX) || (j == endY && k == endX)))) {
					//	trace("[" + nowY + "," + nowX + "] has isWire = " + isWire(j,k));
					//	trace("startpoint = " + (nowX == startX && nowY == startY));
					//	trace("endpoint = " + (nowX == endX && nowY == endY));
						// And if the square is free
							if (!isClosed(j, k)) {
							// And if not closed, then open it
								var movementCost:Number = statusList[nowY][nowX].movementCost + 10;
								if (isOpen(j,k)) {
									// Already opened: check if it's ok to re-open (cheaper)
									if (movementCost < statusList[j][k].movementCost) {
										// Cheaper: simply replaces with new cost and parent.
										openSquare(j, k, [nowY, nowX], movementCost, undefined, true); // heuristic not passed: faster, not needed 'cause it's already set
									}
									
								} else {
									// Else it is empty: open it.
									var heuristic:Number = (Math.abs (j - endY) + Math.abs (k - endX)) * 10;
									openSquare (j, k, [nowY, nowX], movementCost, heuristic, false);
								}
							} else {
								// Already closed, ignore.
							}
						} else {
							// Occupied, ignore.
						}
					}
				}
			}
		}
		var pFound:Boolean = isClosed(endY, endX); // Was the path found?
		
		if (pFound){
			// Ended with path found; generates return path
			var returnPath:Array = [];
			var nowY:Number = endY;
			var nowX:Number = endX;
			
			// Loop through the open list to create the path of points
			while ((nowY != startY || nowX != startX)) {
				returnPath.push([nowY,nowX]);
				var newY:Number = statusList[nowY][nowX].parent[0];
				var newX:Number = statusList[nowY][nowX].parent[1];
				nowY = newY;
				nowX = newX;
			}
			returnPath.push([startY,startX]);
			
			// Print out the message
			var temp:Array = returnPath;
		/*	for (var i:Number = temp.length - 1; i > -1 ; i--) {
				trace("[" + temp[i][0] + "," + temp[i][1] + "]");
			}
		*/	
			// Delete the variables, then reset them
			delete statusList;
			delete openList;
			statusList = [];
			openList = [];
			
			// Reverse the list
			returnPath.reverse();
			
			return (returnPath);
		} else {
			// Ended with 0 open squares; ran out of squares, path NOT found
			return null;
		}
	}
	
	// Checks if a point is closed
	static function isClosed(y:Number, x:Number) : Boolean {
		if (statusList[y][x] == undefined || statusList[y][x] == null)
			return false;
		return statusList[y][x].closed;
	}
	
	// Checks if a point is open
	static function isOpen(y:Number, x:Number) : Boolean {
		if (statusList[y][x] == undefined || statusList[y][x] == null)
			return false;
		return statusList[y][x].open;
	}
	
	static function openSquare(y:Number, x:Number, parent:Array, movementCost:Number, heuristic:Number, replacing:Boolean) : Void {
		if (!replacing || replacing == null) {
			openList.push([y,x]);
			var temp:Object = {heuristic: heuristic, open: true, closed: false};
			statusList[y][x] = temp;
		}
		statusList[y][x].parent = parent;
		statusList[y][x].movementCost = movementCost;
	}
	
	static function closeSquare(y:Number, x:Number) : Void {
		// Drop from the open list
		var len:Number = openList.length;
		for (var i:Number = 0; i < len; i++) {
		  if (openList[i][0] == y) {
			if (openList[i][1] == x) {
			  openList.splice(i, 1);
			  break;
			}
		  }
		}
		// Closes an open square
		statusList[y][x].open = false;
		statusList[y][x].closed = true;
	}
	
	// Returns the square with the lowest F cost from the openList
	static function nearerSquare() : Number {
		// Returns the square with a lower movementCost + heuristic distance
		// from the open list
		var minimum:Number = 999999;
		var indexFound:Number = 0;
		var thisF:Number = undefined;
		var thisSquare:Object = undefined;
		var i:Number = openList.length;
		// Finds lowest
		while (i-- > 0) {
			thisSquare = statusList[openList[i][0]][openList[i][1]];
			thisF = thisSquare.heuristic + thisSquare.movementCost;
			if (thisF <= minimum) {
				minimum = thisF;
				indexFound = i;
			}
		}
		// Returns lowest
		return indexFound;
	}
	
	static function isWire(j: Number, k: Number) : Boolean {
		if (Grid.activeGrid.occupiedGrid[j][k]._type == "wire")
			return true;
		return false;
	}
	
}
