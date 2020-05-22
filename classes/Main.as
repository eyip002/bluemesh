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

 
 
import Utility.XMLParser;

/*
Global Flash variables:

	Declared in ActionScript:
		_global.editing			// Toggling of Edit button in the toolbar.
		
		_global.DrawingArea		// MovieClip of the drawing area made in Main()
		_global.toolBox			// MovieClip of the toolbox made in Main()
		_global.toolBar			// MovieClip of the toolbar made in Main()
		_global.infoBox			// MovieClip of the information box made in Main()

	Declared in HTML:
		_level0.originalNetList	// String containing the XML describing the position of objects drawn
		_level0.originalNets	// String containing the XML describing the relations between objects drawn
		_level0.purpose			// String describing the purpose of BlueMesh: relation, boolean, analog
		_level0.gridSize		// Integer that can be defined to change the grid size
		_level0.teacherMode		// Boolean that defines whether to use BlueMesh in teacher mode.
*/



// The class that contains the main() function executed by Adobe Flash Player.
class Main {
	// Size (px) of the Flash application when compiled.
	private static var _appletSize:Array;
	
	// Padding (px) between the two right-hand panels
	private static var _padding:Number;
	
	// Size (px) of the drawing (grid) area.
	private static var _gridSize:Number;			// Width and height of each grid square.
	private static var _gridWidth:Number;			// Maximum width of the drawing area.
	private static var _gridHeight:Number;			// Maximum height of the drawing area.
	
	// Size (px) of each window element.
	private static var _rightPanelWidth:Number;		// Width of panels on the right-hand side.
	private static var _tabHeight:Number;			// Height (perpendicular to string direction) of tabs.
	private static var _toolBarHeight:Number;		// Height of toolbar.
	private static var _infoBoxHeight:Number;		// Height of the information box (and indirectly, the toolbox).
	
	
	
	// The main function of the BlueMesh program.
	// This is executed by the Adobe Flash Player runtime.
	public static function main() {
		Stage.scaleMode = "noscale";		// Don't allow the Flash applet to be scaled.
		Stage.showMenu = false;				// Hide the right-click context menu options of Flash Player.
		_global.editing = false;			// Turn Edit mode off (Edit button in toolbar).
		
		// Set the options from HTML
		_level0.teacherMode = (_level0.teacherMode == "true");
		
		(_level0.gridSize)
			? _gridSize = Number(_level0.gridSize)
			: _gridSize = 13;
		
		// Set the critical dimensions (px) of BlueMesh elements
		_padding = 25;
		_appletSize = [700 - 1, 500 - 1];
		_rightPanelWidth = 145;
		_tabHeight = 20;
		_toolBarHeight = 35;
		_infoBoxHeight = 100;
		
		_gridWidth = _appletSize[0] - _rightPanelWidth - (_appletSize[0] - _rightPanelWidth)%_gridSize;
		_gridHeight = _appletSize[1] - _toolBarHeight - (_appletSize[1] - _toolBarHeight)%_gridSize;
		
		// Set the dimensions (px) of BlueMesh elements in [x, y, width, height]
		var toolBarDimensions:Array = [	0,
										0,
										_appletSize[0] + 1,
										_toolBarHeight
									  ];
		var drawingAreaDimensions:Array = [	0,
											toolBarDimensions[3],
											_gridWidth,
											_gridHeight,
											_gridSize
										  ];
		var toolBoxDimensions:Array = [	_gridWidth + _tabHeight,
										_toolBarHeight,
										_appletSize[0] - _gridWidth - _tabHeight,
										_gridHeight - _infoBoxHeight - _padding
									  ];
		var infoBoxDimensions:Array = [	_gridWidth,
										_gridHeight - _infoBoxHeight + _toolBarHeight,
										_appletSize[0] - _gridWidth,
										_infoBoxHeight
									  ];
		
		// Instantiate each user interface element using the above dimensions
		_global.drawingArea = new DrawingArea(drawingAreaDimensions);
		if (_level0.teacherMode) {
			_global.infoBox = new InfoBox(infoBoxDimensions);
		}
		_global.toolBox = new ToolBox(toolBoxDimensions);
		_global.toolBar = new ToolBar(toolBarDimensions);
		
		// Parse any netlists passed into BlueMesh.  Redraw the diagram.
		Utility.XMLParser.load(_level0.originalNetList, Utility.Replay.components);
		Utility.XMLParser.load(_level0.originalNets, Utility.Replay.relate);
	}
	
}
