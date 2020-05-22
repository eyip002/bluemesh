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
import circuitComponentLibrary;

// This class describes the ability to replay the drawing of a diagram using static functions.
class Utility.Replay {
	private static var componentMapping:Object = {};
	
	private static function Replay() { };
	
	// This static function places each component onto a temporary panel.
	public static function components(success:Boolean, parsedObject:Object) : Void {
		// Create a temporary panel
		var replayPanel:Panel = new Panel(0, 0, 0, 0);
		
		// Refers to the component created.
		var componentInstantiated:MovieClip;
		
		for (var type:String in parsedObject) {
			for (var instance:String in parsedObject[type]) {
				// Get the XML description of the current object.
				var component:Object = parsedObject[type][instance];									//		<mosfet>
				
				// Place the componet on to the drawing area (same as clicking the component button in the toolbox.
				componentInstantiated = replayPanel.addComponent(type, component.row, component.col);
				
				// Assign a value to it applicable.
				componentInstantiated.value = component.val;
				
				// Add to the list of existing components
				componentMapping[component.id] = componentInstantiated;
				circuitComponentLibrary.componentList.push(componentInstantiated);
			}
		}
		
	}
	
	// This static function makes connections/relations between each replayed component.
	public static function relate(success:Boolean, parsedObject:Object) : Void {
		for (var netGroup:String in parsedObject) {
			// Get the XML description of the current net.
			var connectors:Array = parsedObject[netGroup][0].connectors.split(" ");		// Only one <group> for each net
			
			// Define the connection site to use as the reference for all connectios for a net.
			var rootData:Array = connectors[0].split("_");
			var rootComponent:MovieClip = componentMapping[rootData[0]];
			
			for (var i:Number = 1; i < connectors.length; i++) {
				// Get the connection site of the other component.
				var data:Array = connectors[i].split("_");
				var component:MovieClip = componentMapping[data[0]];
				
				// Programmatically click both connection sites to create the connection/relation.
				rootComponent.connectors[rootData[1]].onPress();
				component.connectors[data[1]].onPress();
			}
		}
	}
	
}
