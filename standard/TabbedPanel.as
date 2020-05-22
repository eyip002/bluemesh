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

import Bttn;


// This class describes a tabbed panel as a MovieClip inside a Panel.
class TabbedPanel extends MovieClip{
	private var _name:String;			// Name of the tabbed panel.
	private var _index:Number;			// Tab number
	private var _depth:Number;			// Depth (z-order)
	private var _selected:Boolean;		// Designation as active tab
	private var _isHovered:Boolean;		// Designation as the current tab being hovered over by the mouse
	
	private var _x:Number;				// x position
	private var _y:Number;				// y position
	private var _w:Number;				// Width of tabbed panel
	private var _h:Number;				// Height of tabbed panel

	private var _tabLength:Number;		// Length of the tab attached to this tabbed panel
	private var _tabHeight:Number;		// Height of the tab attached to this tabbed panel
	
	private var _buttons:Array;			// List of buttons created on this tabbed panel
	private var _overButton:Boolean;	// Whether the mouse is over a button rather than the tabbed panel
	private var _inputFields:Array;		// List of input text boxes on this tabbed panel
	private var _parent:Panel;			// The Panel this tabbed panel belongs to
	
	private var alpha_interval:Number	// Transparency of this tabbed panel
	
	function TabbedPanel() {
		_selected = false;
		_isHovered = false;
		_buttons = new Array();
		_overButton = false;
		_inputFields = new Array();
		this.useHandCursor = false;
		
		drawLabel();
		redraw();
	}
	
	// Function disables all user interface elements when this tabbed panel is no longer the
	// active panel.
	public function deselect() {
		_selected = false;
		this.useHandCursor = true;
		for (var i:Number = 0; i < _buttons.length; i++) {
			_buttons[i].enabled = false;
		}
		for (var i:Number = 0; i < _inputFields.length; i++) {
			_inputFields[i]._visible = false;
		}
		redraw();
	}
	
	// Function enables all user interface elements when the tab of this tabbed panel
	// is clicked.  The tabbed panel is brought to the top as the foremost tabbed panel.
	public function select() {
		_selected = true;
		this.useHandCursor = false;
		for (var i:Number = 0; i < _buttons.length; i++) {
			_buttons[i].enabled = true;
		}
		for (var i:Number = 0; i < _inputFields.length; i++) {
			_inputFields[i]._visible = true;
		}
		
		redraw();
	}
	
	// Function adds a button.
	public function addButton(name:String, onEvent:Function, x:Number, y:Number, w:Number, h:Number) : MovieClip {
		var format:Object = buttonFormat.format(name, onEvent, ++Utility.GDraw.depth, x, y, w, h);
		var button:MovieClip = Utility.McLib.createWithClass(Bttn, this, name, Utility.GDraw.depth, format);
		_buttons.push(button);
		return button;
	}
	
	// Function adds an input text box.  Accepts all characters.
	public function addInputBox(name:String, y:Number, w:Number) : MovieClip {
		var format:Object = {	_rec: {	_x: 5 + _x,
										_y: y + _y,
										_w: w,
										_h: 20
									  }
							};
		Utility.GDraw.addInputBox(_parent.thisPanel, name, ++Utility.GDraw.depth, format)
		_inputFields.push(_parent.thisPanel[name]);
		return _parent.thisPanel[name];
	}
	
	// Function sets the text in a text label in the panel.  Example use: Information box.
	public function setText(name:String, text:String) : Void {
		this[name].text = text;
		this[name].setTextFormat(new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "left"));
	}
	
	// Function appends text to a text label in the panel.  Example use: Information box.
	public function appendText(name:String, text:String) : Void {
		this[name].text += text;
		this[name].setTextFormat(new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "left"));
	}
	
	// Function adds a text label to the panel.  Example use: Information box.
	public function addText(name:String, text:String) : Void {
		var format:Object = {	_rec: {	_x: 5,
										_y: 5,
										_w: _w - 10,
										_h: 40
									  },
								_font: new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "center")
							};
							
		Utility.GDraw.addLabel(this, name, text, ++Utility.GDraw.depth, format);
		this[name].autoSize = true;													// Allow textArea to resize
		this[name].wordWrap  = true;												// Allow bottom of textArea to resize
	}
	
	// Function responds to mouse presses.
	private function onPress() : Void {
		// Check if a button has been clicked on the tabbed panel.
		// This is required because child MovieClips do not get mouse events.
		for (var i:Number = 0; i < _buttons.length; i++) {
			if (_buttons[i].hitTest(_root._xmouse, _root._ymouse, true)) {
				_buttons[i].onRelease();
				return;
			}
		}
		
		// Otherwise, the tab of this tabbed panel has been clicked.  Bring it to the top.
		// Deactivate the other tabs.
		this.swapDepths(_parent.topTab);
		_parent.deactiveOtherTabs(_index);
	}
	
	// Function responds to mouse overs.
	private function onRollOver() : Void {
		_isHovered = true;
		redraw();
	}
	
	// Function responds to mouse out.
	private function onRollOut() : Void {
		_isHovered = false;
		redraw();
	}
	
	// Function responds to the mouse moving.
	private function onMouseMove() : Void {
		// Only respond if it is the active tabbed panel.
		if (_selected) {
			var wasOverButton:Boolean = this._overButton;
			_overButton = false;
			
			// Check what button it the mouse is over.
			for (var i:Number = 0; i < _buttons.length; i++) {
				// If the mouse is over a button.
				if (_buttons[i].hitTest(_root._xmouse, _root._ymouse, true)) {
					// If it wasn't over a button, then give an event to the current button the mouse is over.
					if (!wasOverButton) {
						_buttons[i].onRollOver();
						_overButton = true;
					}
					_overButton = true;				// Set _overButton back to true if the mouse is still over the same button.
				} else {
					// Else the mouse has moved off the button.
					if (wasOverButton) {
						_buttons[i].onRollOut();
					}
				}
			}
			this.useHandCursor = _overButton;		// Set the mouse cursor to a hand for visual consistency.
		}
	}
	
	// Function to draw a text label for the tabbed part of this tabbed panel.
	// Rotate the label so it is vertical.
	private function drawLabel() : Void {
		var name:String = _name + "label";
		var format:Object = {	_rec: {	_x: -_tabHeight,
										_y: (_index+1)*_tabLength,
										_w: _tabLength,
										_h: _tabHeight
									  },
								_font: new TextFormat("library.Vera.ttf", 10, null, null, null, null, null, null, "right", null, 5)
							};
		
		Utility.GDraw.addLabel(this, name, _name, ++Utility.GDraw.depth, format);
		this[name]._rotation = -90;
	}
	
	// Function to redraw the tabbed panel.
	private function redraw() : Void {
		(_selected || _isHovered)
			? this._alpha = 100
			: this._alpha = 50;
		
		this.clear();
		
		Utility.GDraw.color = 0x666666;
		Utility.GDraw.thickness = 1;
		Utility.GDraw.fill = 0xf1f1f1;
		
		// Draw tab
		Utility.GDraw.filledRect(this, -_tabHeight, _index*_tabLength, _tabHeight, _tabLength)
			
		// Draw body
		Utility.GDraw.filledRect(this, 0, 0, _w, _h)
		
		// Remove line between the tab and body
		Utility.GDraw.color = 0xf1f1f1
		Utility.GDraw.line(this, 0, _index*_tabLength + 1, 0, (_index+1)*_tabLength);
		
		Utility.GDraw.fill = 0xffae00;
		Utility.GDraw.color = 0xffae00;
		if (_isHovered && !_selected) {
			Utility.GDraw.filledRect(this, -_tabHeight, _index*_tabLength, 3, _tabLength)
		}
	}
}
