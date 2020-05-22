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


import Utility.Netlist;
import Utility.XMLParser;

// This class describes the different input/output methods for BlueMesh.
class Utility.IO {
	private static function IO() { };
	
	// JavaScript Alert
	// Returns the success of the operation.
	public static function alertJS(text:String) : Boolean {
		fscommand("alertJS", text);
		
		return true;
	}
	
	// JavaScript Prompt
	// Returns the success of the operation.
	public static function promptJS(text:String) : Boolean {
		fscommand("promptJS", text);
		
		return true;
	}
	
	// JavaScript Confirm
	// Returns the success of the operation.
	public static function confirmJS(text:String) : Boolean {
		fscommand("confirmJS", text);
		
		return true;
	}
	
	// Sets the values of various HTML input boxes.
	public static function sendNetlist() : Boolean {
		fscommand("netlist", Utility.Netlist.create());
		fscommand("nets", Utility.Netlist.nets());
		fscommand("boolean", Utility.Netlist.logicExpression());
		return true;
	}
	
}
