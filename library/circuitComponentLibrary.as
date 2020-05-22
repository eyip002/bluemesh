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
 *	 Analog:
 *  	VOLTAGE SOURCE
 *  	CURRENT SOURCE
 *  	GROUND
 * 		RESISTOR
 *  	CAPACITOR
 *  	DIODE
 *  	OPAMP
 *  	MOSFET
 * 
 *   Digital:
 *  	AND
 *  	OR
 *  	NOT
 *  	INPUT / OUTPUT PORTS
 */

// This class contains static functions that return the format of each component.
class circuitComponentLibrary {
	public static var _counter:Object = {};				// Counter for the number of components made for each type.
	public static var _allComponentNames:Array = [];	// Names of all components made.
	public static var componentList:Array = [];			// Pointers to all components made.
	
	private static var defaultFont:TextFormat = new TextFormat("library.VeraBd.ttf", 12, 0xff0000, null, null, null, null, null, "center");
	
	private static function circuitComponentLibrary() { };
	
	// Function to remove all components made.
	public static function clear() : Void {
		for (var component:String in componentList) {
			componentList[component].remove();
		}
	}


	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 					VOLTAGE SOURCE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function voltage(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								  ) : Object {
 		(_counter.voltage)
			? _counter.voltage++			// Increase counter if it exists
			: _counter.voltage = 1;			// Else start the counter
			
		var type:String = "voltage";					// Same as function name
		var _name:String = type + _counter.voltage;		// Name for the instance of the component created.
		_allComponentNames.push(_name);					// Add to the component names
		
		// Width and height of circuit component, in an integer number of grid points
		var width:Number = 3;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,		// Reserve two z-order depths
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,		// Size (px) of the component
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,							// Size of component in an integer number of grid points.
					_height: height
				  },
			_image: "library.components.voltage.png",		// Image to overlay the component with
			connections: [
							[[0, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],		// Position of connection points for every grid square occupied
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 0]]
						  ],
			_panel: panel,		// Panel to attach the component to
			_grid: grid,		// Panel to attach the component to
			_font: defaultFont
		};
	}
	

	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 					CURRENT SOURCE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function current(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								  ) : Object {
 		(_counter.current)
			? _counter.current++
			: _counter.current = 1;
			
		var type:String = "current";
		var _name:String = type + _counter.current;
		_allComponentNames.push(_name);
		
		var width:Number = 3;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.current.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						GROUND
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function ground(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								 ) : Object {
 		(_counter.ground)
			? _counter.ground++
			: _counter.ground = 1;
			
		var type:String = "ground";
		var _name:String = type + _counter.ground;
		_allComponentNames.push(_name);
		
		var width:Number = 3;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.ground.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	
	
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						RESISTOR
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function resistor(	row:Number,
										col:Number,
										panel:Panel,
										grid:Grid
								   ) : Object {
 		(_counter.resistor)
			? _counter.resistor++
			: _counter.resistor = 1;
			
		var type:String = "resistor";
		var _name:String = type + _counter.resistor;
		_allComponentNames.push(_name);
		
		var width:Number = 4;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.resistor.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						 ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						CAPACITOR
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function capacitor(	row:Number,
										col:Number,
										panel:Panel,
										grid:Grid
									) : Object {
 		(_counter.capacitor)
			? _counter.capacitor++
			: _counter.capacitor = 1;
			
		var type:String = "capacitor";
		var _name:String = type + _counter.capacitor;
		_allComponentNames.push(_name);
		
		var width:Number = 3;
		var height:Number = 2;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.capacitor.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						DIODE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function diode(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								) : Object {
 		(_counter.diode)
			? _counter.diode++
			: _counter.diode = 1;
			
		var type:String = "diode";
		var _name:String = type + _counter.diode;
		_allComponentNames.push(_name);
		
		var width:Number = 4;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.diode.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						 ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						OPAMP
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function opamp(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								) : Object {
 		(_counter.opamp)
			? _counter.opamp++
			: _counter.opamp = 1;
			
		var type:String = "opamp";
		var _name:String = type + _counter.opamp;
		_allComponentNames.push(_name);
		
		var width:Number = 4;
		var height:Number = 5;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.opamp.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0],  [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1, 0, 0, 0], [0, 0, 0, 0],  [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0],  [0, 0, 0, 0], [0, 1, 0, 0]],
							[[1, 0, 0, 0], [0, 0, 0, 0],  [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0],  [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						MOSFET
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function mosfet(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								 ) : Object {
 		(_counter.mosfet)
			? _counter.mosfet++
			: _counter.mosfet = 1;
			
		var type:String = "mosfet";
		var _name:String = type + _counter.mosfet;	
		_allComponentNames.push(_name);
		
		var width:Number = 3;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.mosfet.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 1, 0]],
							[[1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 1]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}

	
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						AND GATE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function andGate(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								  ) : Object {
 		(_counter.andGate)
			? _counter.andGate++
			: _counter.andGate = 1;
			
		var type:String = "andGate";
		var _name:String = type + _counter.andGate;
		_allComponentNames.push(_name);
		
		var width:Number = 4;
		var height:Number = 5;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.andGate.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1.1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 0]],
							[[1.1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						 ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						OR GATE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function orGate(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								 ) : Object {
 		(_counter.orGate)
			? _counter.orGate++
			: _counter.orGate = 1;
			
		var type:String = "orGate";
		var _name:String = type + _counter.orGate;
		_allComponentNames.push(_name);
		
		var width:Number = 4;
		var height:Number = 5;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.orGate.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1.1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 0]],
							[[1.1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						 ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	

	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 						NOT GATE
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function notGate(	row:Number,
									col:Number,
									panel:Panel,
									grid:Grid
								 ) : Object {
 		(_counter.notGate)
			? _counter.notGate++
			: _counter.notGate = 1;
			
		var type:String = "notGate";
		var _name:String = type + _counter.notGate;
		_allComponentNames.push(_name);
		
		var width:Number = 3;
		var height:Number = 3;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,
					_height: height
				  },
			_image: "library.components.notGate.png",
			connections: [
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
							[[1.1, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 0]],
							[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
						  ],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * 					INPUT / OUTPUT PORTS
	 * * * * * * * * * * * * * * * * * * * * * * * * * * */
	public static function inOutPort(	row:Number,
										col:Number,
										panel:Panel,
										grid:Grid,
										isInput:Boolean
									) : Object {
 		(_counter.inOutPort)
			? _counter.inOutPort++
			: _counter.inOutPort = 1;
			
		var type:String = (isInput) ? "inPort" : "outPort";
		var _name:String = type + _counter.inOutPort;
		_allComponentNames.push(_name);
		
		var width:Number = 1;
		var height:Number = 1;
		
		return {
			_depth: Utility.GDraw.depth += 2,
			_type: type,
			_text: _name,
			_format: {	_border: 1,
						_bordColor: 0x555555,
						_bordAlpha: 0
					 },
			_hoverFormat: {	_border: 1,
							_bordColor: 0xff0000,
							_bordAlpha: 100
						 },
			_rec: {	_x: col*grid.d + grid.dimensions.x,
					_y: row*grid.d + grid.dimensions.y,
					_w: width * grid.d,
					_h: height * grid.d,
					_width: width,	
					_height: height
				  },
			_image: (isInput) ? "library.components.inPort.png" : "library.components.outPort.png",
			connections: (isInput) ?
							[
								[[0, 1, 0, 0]]
							]
						 : 	[
								[[1.1, 0, 0, 0]]
							],
			_panel: panel,
			_grid: grid,
			_font: defaultFont
		};
	}
}