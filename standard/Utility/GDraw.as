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
 * @author	Eugene Yip & Jeffrey Yan
 * @date	20 September 2008
 */

// This class describes static functions for drawing graphics.
class Utility.GDraw {
	// Depth counter to keep track of depths used (z-order).
	public static var depth:Number = 0;
	
	// Variables required for drawing shapes
	public static var color:Number;				// Line colour
	public static var fill:Number;				// Fill colour
	public static var thickness:Number;			// Line thickness
	
	private static function GDraw() { };
	
	// Function to add a text label to a MovieClip.
	public static function addLabel(	mov:MovieClip,
										name:String,
										text:String,
										d:Number,
										format:Object
								   ) : Void {
		addTextBox (mov, name, text, d, format);	// Add a textbox
		mov[name].selectable = false;				// Make it read-only
		mov[name].autoSize = false;					// Text only visible within label
	}
	
	// Function to add a text box to a MovieClip.
	public static function addTextBox(	mov:MovieClip,
										name:String,
										text:String,
										d:Number,
										format:Object
									 ) : Void {
		mov.createTextField(name, d, format._rec._x, format._rec._y, format._rec._w, format._rec._h);	// Add a TextField to a MovieClip
		mov[name].text = text;					// Add text
		mov[name].setTextFormat(format._font);	// Apply format font
		mov[name].embedFonts  = true;			// Use font specified (embedded)
   }
   
	// Function to add an input text box to a MovieClip.
	public static function addInputBox(	mov:MovieClip,
										name:String,
										d:Number,
										format:Object
									 ) : Void {
   		mov.createTextField(name, d, format._rec._x, format._rec._y, format._rec._w, format._rec._h);	// Add a TextField to a MovieClip
		mov[name].type = "input";				// Change TextField to an input type
		mov[name].maxChars = 16;				// Restrict the number of characters that can be entered.
		mov[name].border = true;				// Allow a border to be drawn around the input box.
		mov[name].borderColor = 0x666666;		// Border colour.
		mov[name].background = true;			// Allow a background colour to be set for the input box.
		mov[name].backgroundColor = 0xffffff;	// Background colour.
	}
   
	// Function to draw a MovieClip as a non filled rectangle.
	public static function nonFilledRect(	mov:MovieClip,
											x1:Number,
											y1:Number,
											width:Number,
											height:Number
										) : Void {
		with(mov) {
			lineStyle(thickness, color);		// Set the line style
			moveTo(x1, y1);						// Specify the origin
			lineTo(x1 + width, y1);				// Draw to the right
			lineTo(x1 + width, y1 + height);	// Draw down
			lineTo(x1, y1 + height);			// Draw to the left
			lineTo(x1, y1);						// Draw up
		}
	}

	// Function to draw a MovieClip as a filled rectangle.
	public static function filledRect(	mov:MovieClip,
										x1:Number,
										y1:Number,
										width:Number,
										height:Number
									 ) : Void {
		mov.beginFill(fill);								// Start the fill
		GDraw.nonFilledRect(mov, x1, y1, width, height);	// Draw the boundary
		mov.endFill();										// End the fill
	}
	
	// Function to draw a line of current thickness and colour.
	public static function line(	mov:MovieClip,
									x1:Number,
									y1:Number,
									x2:Number,
									y2:Number
							   ) : Void {
		with(mov) {
			lineStyle(thickness, color);	// Set the line style
			moveTo(x1, y1);					// Specify the origin
			lineTo(x2, y2);					// Draw to destination
		}
	}
	
	// Function to apply graphics to a MovieClip.
	public static function formatMovClip(	mov:MovieClip,
											format:Object,
											rec:Object
									    ) : Void {
		with(mov) {
			lineStyle(format._border, format._bordColor, format._bordAlpha);		//Set the line style of the border
			
			(format._matrix == undefined)		// Begin the fill
				? beginFill(0,0,0)
				: beginGradientFill(format._fillType, format._colors, format._alphas, format._ratios, format._matrix);
			
			moveTo(0, 0);				// Specify the origin
			lineTo(rec._w, 0);			// Draw to the right
			lineTo(rec._w, rec._h);		// Draw down
			lineTo(0, rec._h);			// Draw to the left
			endFill(0, 0);				// Draw up
			_x = rec._x;				// Set the location of the top-left corner of the MovieClip
			_y = rec._y;
		}
	}
	
	// Function to style a MovieClip like a toolbar.
	public static function toolBarStyle(	mov:MovieClip,
											rec:Object
									   ) : Void {
		with(mov) {
			var format:Object = {	_colors: [0xe1e1e1, 0xdddddd, 0xb1b1b1, 0x8f8f8f],		// Define the toolbar style
									_alphas: [100, 100, 100, 100],
									_ratios: [0, 50, 205, 255],
									_matrix: {	matrixType:"box",
												x: 0, 
												y: 0,
												w: rec.w,
												h: rec.h,
												r: 0.5*Math.PI
											 }
								 };
								 
			lineStyle(0, 0x000000, 0);	// Define the line style for the border
			beginGradientFill("linear", format._colors, format._alphas, format._ratios, format._matrix);	// Begin the fill 
			moveTo(0, 0);				// Specify the origin.
			lineTo(rec.w, 0);			// Draw to the right.
			lineTo(rec.w, rec.h);		// Draw down.
			lineTo(0, rec.h);			// Draw to the left.
			endFill(0, 0);				// Draw up.
		}
	}
}
