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


// This class contain(s) static function(s) that return the look of buttons.
class buttonFormat {
	private static function buttonFormat() { };
	
	// Static function that returns an object describing the look of a button.
	public static function format(	name:String,
									onEvent:Function,
									tabIndex:Number,
									x:Number,
									y:Number,
									w:Number,
									h:Number
								 ) : Object {
		return {
			_text: name,													// Text to display on the button.
			_onEvent: onEvent,												// Function called on each mouse event on the button.
			_format: {	_fillType: "linear",								// Fill type of gradient: linear or radial.
						_colors: [0xe1e1e1, 0xdddddd, 0xb1b1b1, 0x8f8f8f],	// Colours used for fill.
						_alphas: [100, 100, 100, 100],						// Alpha of each colour.
						_ratios: [0, 80, 170, 255],							// Placement of each colour in the fill.
						_matrix: {	matrixType:"box",						// Matrix defining the transformation of the fill.
									x: 0, 
									y: 0,
									w: w,
									h: h,
									r: 0.5*Math.PI
								 },
						_border: 1,											// Weight (px) of border around the button.
						_bordColor: 0x888888,								// Colour of border.
						_bordAlpha: 100										// Alpha or border.
					 },
			_hoverformat: {	_fillType: "linear",
							_colors: [0xffffff, 0xefefef, 0xc1c1c1, 0x9f9f9f],
							_alphas: [100, 100, 100, 100],
							_ratios: [0, 80, 170, 255],
							_matrix: {	matrixType:"box",
										x: 0, 
										y: 0,
										w: w,
										h: h,
										r: 0.5*Math.PI
									 },
							_border: 1,
							_bordColor: 0x666666,
							_bordAlpha: 100
						  },
			_activeformat: {	_fillType: "linear",
								_colors: [0xffffff, 0xefefef, 0xc1c1c1, 0x9f9f9f],
								_alphas: [100, 100, 100, 100],
								_ratios: [0, 80, 170, 255],
								_matrix: {	matrixType:"box",
											x: 0, 
											y: 0,
											w: w,
											h: h,
											r: 0.5*Math.PI
										 },
								_border: 1,
								_bordColor: 0x888888,
								_bordAlpha: 100
						   },
			_rec: {	_x: x,		// Size of button to draw.
					_y: y,
					_w: w,
					_h: h
				  },
			_font: new TextFormat("library.Vera.ttf", 12, null, null, null, null, null, null, "center"),		// Font to use for text
			tabIndex: tabIndex,																					// Number of tabs required to select the button.
			tabEnabled: true																					// Allow tabbing for navigation.
		};
	}
	
}