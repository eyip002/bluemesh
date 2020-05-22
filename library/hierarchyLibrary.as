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
 * @author	Eugene Yip
 * @date	20 September 2008
 */


/* Components available:
 * 		topLevel
 *		middleLevel
 * 		bottomLevel
 */


// This class describes static functions that return the format of each component
class hierarchyLibrary {
	public static var _counter:Object = {};				// Counter for the number of components made for each type.
	public static var _allComponentNames:Array = [];	// Names of all components made.
	public static var componentList:Array = [];			// Pointers to all components made.
	
	private static var defaultFont:TextFormat = new TextFormat("library.VeraBd.ttf", 12, 0xff0000, null, null, null, null, null, "center");
	
	private static function hierarchyLibrary() { };
	
	// Function to remove all components made.
	public static function clear() : Void {
		for (var component:String in componentList) {
			componentList[component].remove();
		}
	}


	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 					Top level
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function topLevel(	row:Number,
										col:Number,
										panel:Panel,
										grid:Grid
								   ) : Object {
 		(_counter.topLevel)
			? _counter.topLevel++			// Increase counter if it exists
			: _counter.topLevel = 1;		// Else start the counter
			
		var type:String = "topLevel";					// Same as function name
		var _name:String = type + _counter.topLevel;	// Name for the instance of the component created.
		_allComponentNames.push(_name);					// Add to the component names
		
		// Width and height of circuit component, in an integer number of grid points
		var width:Number = 7;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,		// Reserve two z-order depths
			_type: type,
			_text: _name,
			_format: {	_fillType: "linear",
						_colors: [0xffdcdc],
						_alphas: [100],
						_ratios: [0],
						_matrix: {	matrixType:"box",
									x: 0, 
									y: 0,
									w: width * grid.d,
									h: height * grid.d,
									r: 0
								 },
						_border: 2,
						_bordColor: 0xdd0000,
						_bordAlpha: 100
					 },
			_hoverFormat: {	_fillType: "linear",
							_colors: [0xffffff],
							_alphas: [100],
							_ratios: [0],
							_matrix: {	matrixType:"box",
										x: 0, 
										y: 0,
										w: width * grid.d,
										h: height * grid.d,
										r: 0
									 },
							_border: 4,
							_bordColor: 0xdd0000,
							_bordAlpha: 100
						  },
			_rec: {	_x: col*grid.d + grid.dimensions.x,		// Size (px) of the component
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,							// Size of component in an integer number of grid points.
					_height: height
				  },
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],		// Position of connection points for every grid square occupied
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,		// Panel to attach the component to
			_grid: grid,		// Panel to attach the component to
			_font: defaultFont
		};
	}
	

	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 					Middle level
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function middleLevel(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								  ) : Object {
 		(_counter.middleLevel)
			? _counter.middleLevel++
			: _counter.middleLevel = 1;
			
		var type:String = "middleLevel";
		var _name:String = type + _counter.middleLevel;
		_allComponentNames.push(_name);
		
		var width:Number = 7;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_fillType: "linear",
						_colors: [0xdcffdd],
						_alphas: [100],
						_ratios: [0],
						_matrix: {	matrixType:"box",
									x: 0, 
									y: 0,
									w: width * grid.d,
									h: height * grid.d,
									r: 0
								 },
						_border: 2,
						_bordColor: 0x009900,
						_bordAlpha: 100
					 },
			_hoverFormat: {	_fillType: "linear",
							_colors: [0xffffff],
							_alphas: [100],
							_ratios: [0],
							_matrix: {	matrixType:"box",
										x: 0, 
										y: 0,
										w: width * grid.d,
										h: height * grid.d,
										r: 0
									 },
							_border: 4,
							_bordColor: 0x009900,
							_bordAlpha: 100
						  },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 1.1, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						Bottom level
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function bottomLevel(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								  ) : Object {
 		(_counter.bottomLevel)
			? _counter.bottomLevel++
			: _counter.bottomLevel = 1;
			
		var type:String = "bottomLevel";
		var _name:String = type + _counter.bottomLevel;
		_allComponentNames.push(_name);
		
		var width:Number = 7;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_fillType: "linear",
						_colors: [0xdceeff],
						_alphas: [100],
						_ratios: [0],
						_matrix: {	matrixType:"box",
									x: 0, 
									y: 0,
									w: width * grid.d,
									h: height * grid.d,
									r: 0
								 },
						_border: 2,
						_bordColor: 0x0000ff,
						_bordAlpha: 100
					 },
			_hoverFormat: {	_fillType: "linear",
							_colors: [0xffffff],
							_alphas: [100],
							_ratios: [0],
							_matrix: {	matrixType:"box",
										x: 0, 
										y: 0,
										w: width * grid.d,
										h: height * grid.d,
										r: 0
									 },
							_border: 4,
							_bordColor: 0x0000ff,
							_bordAlpha: 100
						  },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 1.1, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
}