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

// This class describes the drawing area with a panel overlaid with a grid.
class DrawingArea {
	public var drawingPanel:Panel;
	
	function DrawingArea(panelSize:Array) {
		// Create a new panel.
		drawingPanel = new Panel(panelSize[0], panelSize[1], panelSize[2], panelSize[3]);
		
		// Overlay the panel with a grid.
		drawingPanel.overlayGrid("grid1", panelSize[4]);
		
		// Draw a border around the panel.
		drawingPanel.drawBorder(1, 0x0000FF, 100);
	}

} 

