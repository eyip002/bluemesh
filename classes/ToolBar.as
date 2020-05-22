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



import Utility.IO;
import Utility.XMLParser;
import Utility.Netlist;
import Utility.Replay;

import Panel;


// This class describes the toolbar with a panel and a series of buttons
class ToolBar {
	function ToolBar(panelSize:Array) {
		// Create a new panel and style it.
		var toolBar:Panel = new Panel(panelSize[0], panelSize[1], panelSize[2], panelSize[3]);
		toolBar.toolBarStyle();
		
		// Create a series of buttons
		var bName:Array = ["Save", "Edit", "Clear", "Load", "Draw"];					// Button names
		var widths:Array = [35, 35, 40, 55, 55];										// Width of each button
		var positions:Array = [5, 45, 85, panelSize[2] - 120, panelSize[2] - 60];		// Position of each button
		for (var i:Number = 0; i < bName.length; i++) {
			// Create each button.
			toolBar.addButton(bName[i], onEvent, positions[i], 5, widths[i], 25);		// onEvent points to a function defined below
		}
		toolBar.thisPanel["edit"].isToggling = true;		// Set the Edit button to be a toggling button.
	}
	
	// Function that is called every time a mouse event occurs for a button.
	private function onEvent(state:String, button:Object) : Void {
		// Redraw the look of the button.
		button.redraw();
		
		// When the button has been clicked on the spot.
		if(state == "mouseUp") {
			_global.infoBox.setText(button._text + " clicked");		// Display a message in the information box
			
			switch(button._text) {
				case("Save"):	// Send the netlist to HTML
								_global.infoBox.appendText("\n" + Utility.IO.sendNetlist());
								break
								
				case("Clear"):	// Clear the drawing area
								circuitComponentLibrary.clear();
								break;
								
				case("@"):		// Display a JavaScript alert box.
								_global.infoBox.appendText("\n" + Utility.IO.alertJS("This is a message box called from within Flash."));
								break;
								
				case("~>"):		// Display a JavaScript prompt box.
								_global.infoBox.appendText("\n" + Utility.IO.promptJS("Type in you response below:"));
								break;
								
				case("#"):		// Display a JavaScript confirmation box.
								_global.infoBox.appendText("\n" + Utility.IO.confirmJS("Proceed with the random action?"));
								break;
								
				case("Edit"):	// Toggle Edit mode on and off.
								_global.editing = !_global.editing;			// Toggle the editing mode
								if (!_global.editing) {						// If the mode is no longer editing, then deselect the
									DragObject.activeObject.onRollOut();	// current dragObject.
									DragObject.activeObject = null;
								}
								_global.infoBox.appendText("\nedit tool selected (" + _global.editing + ")");
								break;
								
								
				case("Load"):	// Display two prompts for the XML netlists.
								Utility.IO.promptJS("object");
								Utility.IO.promptJS("relational");
								break;
									
				case("Draw"):	// Redraws the diagram loaded by the two XML netlists.  Clears drawing area before redrawing.
								circuitComponentLibrary.clear();
								Utility.XMLParser.load(_level0.originalNetList, Utility.Replay.components);
								Utility.XMLParser.load(_level0.originalNets, Utility.Replay.relate);
								break;
									
				default:		break;
			}
		}
	}
	
}
