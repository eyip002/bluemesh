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
 
// This class describes a button in BlueMesh as a MovieClip.
class Bttn extends MovieClip {
	private var _d:Number;				// Depth (z-order) of the button
	private var _text:String;			// Button text
	private var _font:Object;			// Font format
	private var _onEvent:Function;		// Function to invoke when a mouse event happens
	private var _rec:Object;			// Button dimensions
	
	private var _format:Object;			// Base format
	private var _hoverformat:Object;	// Hover format
	private var _activeformat:Object	// Toggle format
	private var _currentFormat:Object	// Place holder for the current format

	private var _isToggling:Boolean;	// Sets button as toggling
	private var _isActive:Boolean;		// When in toggle mode, keeps track of the button's state
	
	
	
	function Bttn() {   
		_currentFormat = _format;		// Set current format to base format
		drawLabel();					// Add a text label to the button
		redraw();						// Draw the MovieClip
	}

	// Required to be in mouseOver/mouseUp state for this
	// function to be called
	private function onPress() : Void {
		(_isToggling) ? _isActive = !_isActive : null;
		_onEvent("mouseDown", this);
	}
   
	// Required to be in mouseDown state for this
	// function to be called
	private function onRelease() : Void {
		_onEvent("mouseUp", this);
	}
   
	// Required to be in mouseOut state for this
	// function to be called
	private function onRollOver() : Void {   
		//change button to hover format
		_currentFormat = _hoverformat;
		_onEvent("mouseOver", this);	//invoke event Function
	}
   
	// Required to be in mouseUp/mouseOver state for this
	// function to be called
	private function onRollOut() : Void {
		(_isActive)
			? _currentFormat = _activeformat
			: _currentFormat = _format
		_onEvent("mouseOut", this);
	}
	
	// Function sets button as toggling or not.
	public function set isToggling(toggling:Boolean) : Void {
		_isToggling = toggling;
	}
	
	// Function draws the text label of the button.
	private function drawLabel() : Void {
		//create label object containing area and location to top, left (for centering)
		var format:Object = {	_rec: {	_x: 0,
										_y: 5,
										_w: _rec._w,
										_h: _rec._h
									  },
								_font: _font
							}
		Utility.GDraw.addLabel(this, "bttnLabel", _text, 1, format);		// Add label to the button
	}
	
	// Redraw the colour style of the button.
	public function redraw() : Void {
		this.clear();												// Clear this MovieClip
		Utility.GDraw.formatMovClip(this, _currentFormat, _rec);	// style the button MovieClip
	}

} 