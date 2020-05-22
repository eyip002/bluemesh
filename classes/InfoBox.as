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

// This class describes the information box with a panel with text.
class InfoBox {
	public var infoPanel:Panel;
	
	
	function InfoBox(panelSize:Array) {
		// Create a new panel
		infoPanel = new Panel(panelSize[0], panelSize[1], panelSize[2], panelSize[3]);
		
		// Add a title bar
		infoPanel.drawTitleBar(false, "Information");
		infoPanel.drawBorder(1, 0x666666, 100);
		
		// Set the initial text inside the panel
		infoPanel.addText("debug", "\n\nDebugging");
	}
	
	// Function to set the text.
	public function setText(text:String) : Void {
		infoPanel.setText("debug", text);
	}
	
	// Function to append to the existing text.
	public function appendText(text:String) : Void {
		infoPanel.appendText("debug", text);
	}
}
