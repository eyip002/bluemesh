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

import Panel;
 
// This class describes the toolbox as a panel with many tabbed panels and buttons.
class ToolBox {
	public var toolPanel:Panel;
	
	function ToolBox(panelSize:Array) {
		// Create a new panel and give it a title bar.
		toolPanel = new Panel(panelSize[0], panelSize[1], panelSize[2], panelSize[3]);
		toolPanel.drawTitleBar(true, "Components");
		
		// Create the correct tab with correct components (as specified by the HTML variable).
		var tab0:MovieClip;
		if (_level0.purpose == "analog") {
			tab0 = toolPanel.addTab("Common");
			
			tab0.addButton("voltage", onEvent, 5, 5, 60, 25);
			tab0.addButton("current", onEvent, 5, 40, 60, 25);
			tab0.addButton("ground", onEvent, 5, 75, 50, 25);
			tab0.addButton("resistor", onEvent, 5, 145, 60, 25);
			tab0.addButton("capacitor", onEvent, 5, 180, 60, 25);
			tab0.addButton("diode", onEvent, 5, 215, 40, 25);
			tab0.addButton("opamp", onEvent, 5, 250, 50, 25);
		} else if (_level0.purpose == "boolean") {
			tab0 = toolPanel.addTab("Logic  ");
			
			tab0.addButton("andGate", onEvent, 5, 5, 60, 25);
			tab0.addButton("orGate", onEvent, 5, 40, 50, 25);
			tab0.addButton("notGate", onEvent, 5, 75, 60, 25);
			
			tab0.addButton("inPort", onEvent, 5, 145, 50, 25);
			tab0.addButton("outPort", onEvent, 5, 180, 60, 25);
		} else if (_level0.purpose == "relation") {
			tab0 = toolPanel.addTab("Relation");
			
			tab0.addButton("topLevel", onEvent, 5, 5, 60, 25);
			tab0.addButton("middleLevel", onEvent, 5, 40, 80, 25);
			tab0.addButton("bottomLevel", onEvent, 5, 75, 80, 25);
		} else {
			tab0 = toolPanel.addTab("Default");
			
			tab0.addButton("voltage", onEvent, 5, 5, 60, 25);
		}
		
		// Add a Settings tab for changing component text value.
		var tab3:MovieClip = toolPanel.addTab("Settings");
		tab3.addText("settings", "Settings:");
		tab3.appendText("settings", "\n\nChange component value:");
		tab3.addButton("Change", onEvent, 5, 100, 55, 25);
		
		// Add an About tab for BlueMesh information.
		var tab4:MovieClip = toolPanel.addTab("About  ");
		tab4.addText("about", "BlueMesh:");
		tab4.appendText("about", "\nVersion 0.95 Beta");
		tab4.appendText("about", "\nAn online relational editor. Licensed under the GNU General Public License.\n\nEugene Yip & Jeffrey Yan");
		tab4.appendText("about", "\n\nMode:\n" + _level0.purpose + "\n");
		tab4.appendText("about", "\nFlash Player details:");
		tab4.appendText("about", "\n* " + System.capabilities.version);
		tab4.appendText("about", "\n* " + System.capabilities.os);
		tab4.appendText("about", "\n* x: " + System.capabilities.screenResolutionX);
		tab4.appendText("about", "\n* y: " + System.capabilities.screenResolutionY);
		
		// Add an input box tot he Settings tab (issue with movie clip depth).
		tab3.addInputBox("number", 70, panelSize[2] - 10);
		
		// Prgrammatically "press" the first tab.
		tab0.onPress();
	}
	
	// Function that is called every time a mouse event occurs for a button.
	private function onEvent(state:String, button:Object) : Void {
		button.redraw();
		
		if(state == "mouseUp") {
			switch(button._text) {
				case("Change"):	// Clicking the Change button in the Settings tab
								if (DragObject.activeObject != null) {		// Must be in Edit mode.
									DragObject.activeObject.value = button._parent._inputFields[0].text;
								}
								break;
									
				default:		// Clicking a component button
								circuitComponentLibrary.componentList.push(_global.toolBox.toolPanel.addComponent(button._text, 1, 1));
								break;
			}
		}
	}
	
}
