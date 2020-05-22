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



import Utility.GDraw;
import Utility.McLib;
import Utility.PathFinding;

import Bttn;
import Component;
import TabbedPanel;
import Grid;


// This class describes a panel in BlueMesh using a MovieClip.
// Panels contain user interface elements like buttons, tabbed panels, text and grid overlay.
class Panel {
	public static var count:Number = 0;		// Records the number of panels created.
	
	public var name:String;					// Name of this panel (automatically generated).
	public var grid:MovieClip;				// Drawing area.
	
	private var x:Number;					// x (px) location of the panel.
	private var y:Number;					// y (px) location of the panel.
	private var w:Number;					// Width (px) of the panel.
	private var h:Number;					// Height (px) of the panel.
	private var titleBarHeight:Number;		// Height (px) of the panel title bar if specified.
	
	private var tabs:Array = new Array();	// Array of tabbed panels created.
	public var topTab:Number;				// Active tabbed panel.
	
	public var thisPanel:MovieClip;			// Pointer to this panel's MovieClip for use in user interface elements.
	
	public function Panel(x:Number, y:Number, w:Number, h:Number) {
		name = "panel" + count++
		
		titleBarHeight = 20;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		
		this.grid = null;
		
		thisPanel = _root.createEmptyMovieClip(name, ++Utility.GDraw.depth);	// MovieClip of this panel.
	}
	
	// Function adds a button to the panel.
	public function addButton(name:String, onEvent:Function, x:Number, y:Number, w:Number, h:Number) : MovieClip {
		var format:Object = buttonFormat.format(name, onEvent, ++Utility.GDraw.depth, x + this.x, y + this.y, w, h);
		return Utility.McLib.createWithClass(Bttn, thisPanel, name, Utility.GDraw.depth, format);
	}
	
	// Function adds a tabbed panel to this panel.
	public function addTab(name:String): MovieClip {
		var depth:Number = ++Utility.GDraw.depth
		var index:Number = tabs.length;
		
		var format:Object = {	_name: name,
								_index: index,
								_x: x,
								_y: y,
								_w: w,
								_h: h,
								_tabLength: 50,
								_tabHeight: 15,
								_parent: this
							};
		
		var tab:MovieClip = Utility.McLib.createWithClass(TabbedPanel, thisPanel, name, depth, format);
		tabs.push(tab);
		
		this.topTab = depth;
		return tab;
	}
	
	// Function deactivates all other tabbed panels when a tabbed panel is clicked.
	// Required because child MovieClips (tabbed panels) do not get mouse events.
	public function deactiveOtherTabs(activeTab:Number) : Void {
		for (var i:Number = 0; i < tabs.length; i++) {
			if (i == activeTab) {
				tabs[i].select();
			} else {
				tabs[i].deselect();
			}
		}
	}
	
	// Function adds a text label to the panel.  Example use: Information box.
	public function addText(name:String, text:String) : Void {
		var format:Object = {	_rec: {	_x: 0 + x,
										_y: 0 + y,
										_w: w,
										_h: h
									  },
								_font: new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "center")
							}
							
		Utility.GDraw.addLabel(thisPanel, name, text, ++Utility.GDraw.depth, format);
	}
	
	// Function sets the text in a text label in the panel.  Example use: Information box.
	public function setText(name:String, text:String) : Void {
		thisPanel[name].text = text;
		thisPanel[name].setTextFormat(new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "left"));
	}
	
	// Function appends text to a text label in the panel.  Example use: Information box.
	public function appendText(name:String, text:String) : Void {
		thisPanel[name].text = thisPanel[name].text + text;
		thisPanel[name].setTextFormat(new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "left"));
	}
	
	// Function adds components to the active drawing area when a component button is clicked.
	public function addComponent(type:String, row:Number, col:Number) : MovieClip {
		var format:Object;
		
		switch(type) {
			case("voltage"):	format = circuitComponentLibrary.voltage(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("current"):	format = circuitComponentLibrary.current(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("ground"):		format = circuitComponentLibrary.ground(row, col, _root[this.name], Grid.activeGrid);
								break;
								
								
			case("mosfet"):		format = circuitComponentLibrary.mosfet(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("resistor"):	format = circuitComponentLibrary.resistor(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("capacitor"):	format = circuitComponentLibrary.capacitor(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("diode"):		format = circuitComponentLibrary.diode(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("opamp"):		format = circuitComponentLibrary.opamp(row, col, _root[this.name], Grid.activeGrid);
								break;
								
								
			case("andGate"):	format = circuitComponentLibrary.andGate(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("orGate"):		format = circuitComponentLibrary.orGate(row, col, _root[this.name], Grid.activeGrid);
								break;
								
			case("notGate"):	format = circuitComponentLibrary.notGate(row, col, _root[this.name], Grid.activeGrid);
								break;
								
								
			case("inPort"):		format = circuitComponentLibrary.inOutPort(row, col, _root[this.name], Grid.activeGrid, true);
								break;
								
			case("outPort"):	format = circuitComponentLibrary.inOutPort(row, col, _root[this.name], Grid.activeGrid, false);
								break
								
								
			case("topLevel"):		format = hierarchyLibrary.topLevel(row, col, _root[this.name], Grid.activeGrid, false);
									break
								
			case("middleLevel"):	format = hierarchyLibrary.middleLevel(row, col, _root[this.name], Grid.activeGrid, false);
									break
								
			case("bottomLevel"):	format = hierarchyLibrary.bottomLevel(row, col, _root[this.name], Grid.activeGrid, false);
									break
			default:			break;
		}
		return Utility.McLib.createWithClass(Component, thisPanel, format._text, Utility.GDraw.depth, format);	// circuitComponentLibrary has already incremented the depth
	}
	
	// Function overlays a grid to this panel.
	public function overlayGrid(name:String, spacing:Number) : Void {
		// Create the grid
		var gridInit:Object = {dimensions: {	x: this.x,
												y: this.y,
												w: this.w,
												h: this.h
											}, 
						d: spacing
				       };
		// Initialise the PathFinding class with the grid size (is not done independently of each grid).
		Utility.PathFinding.mapH = this.h/gridInit.d;
		Utility.PathFinding.mapW = this.w/gridInit.d;
					   
		this.grid = Utility.McLib.createWithClass(Grid, thisPanel, name, ++Utility.GDraw.depth, gridInit);
	}
	
	// Function draws a title bar to the top of the panel.  The body of the panel is automatically decreased.
	public function drawTitleBar(hasTabs:Boolean, titleBarText:String) : Void {
		var textFormat:Object = {	_rec: {	_x: x + 5,
											_y: y + 2,
											_w: w - 10,
											_h: titleBarHeight
										  },
									_font: new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "left")
								};
							
		var titleBarFormat:Object = {	_colors: [0xbddbea, 0x9ac5f2, 0x578cc2, 0x567997],
										_alphas: [100, 100, 100, 100],
										_ratios: [0, 50, 205, 255],
										_matrix: {	matrixType:"box",
													x: x, 
													y: y,
													w: w,
													h: titleBarHeight,
													r: 0.5*Math.PI
												 }
									};
		
		thisPanel.lineStyle(1, 0x666666, 100);
		thisPanel.beginGradientFill("linear", titleBarFormat._colors, titleBarFormat._alphas, titleBarFormat._ratios, titleBarFormat._matrix);
		switch(hasTabs) {
			case (true):	thisPanel.moveTo(x - 15, y);
							thisPanel.lineTo(x + w, y);
							thisPanel.lineTo(x + w, y + titleBarHeight);
							thisPanel.lineTo(x - 15, y + titleBarHeight);
							thisPanel.lineTo(x - 15, y);
							textFormat._rec._x = x - 10;
							break;
							
			case (false):	thisPanel.moveTo(x, y);
							thisPanel.lineTo(x + w, y);
							thisPanel.lineTo(x + w, y + titleBarHeight);
							thisPanel.lineTo(x, y + titleBarHeight);
							thisPanel.lineTo(x, y);
							break;
							
			default:		break;
		}
		thisPanel.endFill(0, 0);
		
		Utility.GDraw.addLabel(thisPanel, name, titleBarText, ++Utility.GDraw.depth, textFormat);
		
		this.y = y + titleBarHeight;
		this.h = h - titleBarHeight;
	}   
	
	// Function draws a border around the panel.
	public function drawBorder(thickness:Number, rgb:Number, alpha:Number) : Void {
		this.lineStyle(thickness, rgb, alpha);
		this.moveTo(x, y);
		this.lineTo(x + w, y);
		this.lineTo(x + w, y + h);
		this.lineTo(x, y + h);
		this.lineTo(x, y);

	}
	
	// Function fills the panel with a colour
	public function fillRect(rgb:Number) : Void {
		thisPanel.beginFill(rgb);
		thisPanel.moveTo(x, y);
		thisPanel.lineTo(x + w, y);
		thisPanel.lineTo(x + w, y + h);
		thisPanel.lineTo(x, y + h);
		thisPanel.lineTo(x, y);
		thisPanel.endFill();
	}
	
	// Function styles the panel as a toolbar.
	public function toolBarStyle() : Void {
		Utility.GDraw.toolBarStyle(thisPanel, {w: w, h: h});
	}
	
	// Function sets the line style for drawing on the panel MovieClip.
	public function lineStyle(thickness:Number, rgb:Number, alpha:Number) : Void {
		thisPanel.lineStyle(thickness, rgb, alpha);
	}
	
	// Function moves the drawing origin for the panel MovieClip.
	public function moveTo(x:Number, y:Number) : Void {
		thisPanel.moveTo(x, y);
	}
	
	// Function draws a line to the destination on the panel MovieClip.
	public function lineTo(x:Number, y:Number) : Void {
		thisPanel.lineTo(x, y);
	}
}
