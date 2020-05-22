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
 * @author	Jeffrey Yan
 * @date	20 September 2008
 */

import gs.dataTransfer.XMLParser;
import Utility.DelegateFD;

class Utility.Netlist {	
	// XML string organised in components/connectors/nets
	public static function create() : String {
		
		// REPLACE FUNCTION DOESN'T WORK
		String.prototype.replace = function(oldString:String, newString:String) : String {
			var split:Array = this.split(oldString);
			var temp:String = new String();
			for (var i:Number = 0; i < split.length; i++) {
				temp += (i != (split.length - 1)) ? split[i] + newString : split[i];
			}
			return temp;
		};
		
		// Generate the required netlist variables
		var netObj:Object = generateNets();
		
		var connectorList:Array = netObj.connectorList;
		var assignedNets:Array = netObj.assignedNets;
		
		// Create an object to send, populate it with values
		var netlist_obj:Object = new Object();
		
		// Temporary storage variables
		var currentComponent:Component;
		var currentConnectorsArray:Array;
		var currentConnectorsObj:Object;
		
		// For each connector
		for (var i:Number = 0; i < connectorList.length; i++) {
			// When a new component is encountered
			if (connectorList[i]._parent != currentComponent) {
				// If it's tag name does not currently exist (i.e. <mosfet ....)
				if (!netlist_obj[connectorList[i]._parent.type])
					netlist_obj[connectorList[i]._parent.type] = new Array(); // Create an array for it
				
				// Point at the current component
				currentComponent = connectorList[i]._parent;
				
				// Create a temp array/object to store all the connectors
				var tempConnectorsArray:Array = new Array();
				currentConnectorsArray = tempConnectorsArray;
				var tempConnectorsObj:Object = new Object();
				currentConnectorsObj = tempConnectorsObj;
			}
			
			// Push the current connector's attributes into the temp object
			if (assignedNets[i] != null) {
				currentConnectorsObj[connectorList[i].name] = new String();
				currentConnectorsObj[connectorList[i].name] += "_" + assignedNets[i];
			}
			
			// If it's the last connector of this component
			if (connectorList[i]._parent != connectorList[i+1]._parent) {
				// Push the connector object into the array
				currentConnectorsArray.push(currentConnectorsObj);
				netlist_obj[connectorList[i]._parent.type].push({connectors:currentConnectorsArray, id:currentComponent.text, val:currentComponent.value, row:currentComponent.topLeftGridPoint[0], col:currentComponent.topLeftGridPoint[1]});
			}
		}
		
		// Convert to XML
		var parsedObject:Object; // We'll use this to hold the parsed xml response.
		parsedObject = Utility.XMLParser.objectToXML(netlist_obj, "circuit");
		
		return parsedObject.toString();//.split("=").join("~");
	}
	
	// XML string organised in nets/connectors
	public static function nets() : String {
		// Generate the required netlist variables
		var netObj:Object = generateNets();
		
		var connectorList:Array = netObj.connectorList;
		var nets:Array = netObj.nets;
		var assignedNets:Array = netObj.assignedNets;
		
		// Create an object to send, populate it with values
		var netlist_obj:Object = new Object();
		
		for (var i:Number = 0; i < nets.length; i++) {
			netlist_obj["_" + i] = new Array();
			
			var connectorListString:String = "";
			
			for (var j:Number = 0; j < nets[i].length; j++) {
				connectorListString += connectorList[nets[i][j]].name;
				
				connectorListString += (j != (nets[i].length - 1)) ? " " : "";
			}
			netlist_obj["_" + i].push({connectors:connectorListString});
		}
		
		// Convert to XML
		var parsedObject:Object; // We'll use this to hold the parsed xml response.
		parsedObject = Utility.XMLParser.objectToXML(netlist_obj, "nets");
		
		return parsedObject.toString();//.split("=").join("~");;
	}
	
	// Generate useful netlist variables
	private static function generateNets() : Object {
		
		// Simple array search function
		Array.prototype.has = function(val:Number) : Boolean {
			for (var i:Number = 0; i < this.length; i++) {
				if (val == this[i])
					return true;
			}
			return false;
		};
		
		// 1D Arrays
		var connectorList:Array = new Array(); // A list of pointers to each connector and wire
		var assignedNets:Array = new Array(); // The net number for each item in connectorList
		
		// 2D Arrays
		var connectedLists:Array = new Array(); // A 2D array of everything connected to each connector and wire
		var indexedConnectedLists:Array = new Array(); // connectedLists using indexes instead of names, may not be in order
		
		// ================================ INDEX LIST CREATION ================================
		// For each wire
		for (var i:Number = 0; i < Wire.wireList.length; i++) {
			// Keep a pointer to this particular wire
			connectorList.push(Wire.wireList[i]);
			// Push all connectors connected to this wire into non-indexed and indexed lists
			connectedLists[i] = new Array();
			indexedConnectedLists[i] = new Array();
			// For each pin or wire in wireList[i]'s _connected list, on both ends
			var connected:Array = Wire.wireList[i].connected;
			for (var end:Number = 0; end < 2; end++) {
				// For each component connected to that wire end
				for (var j:Number = 0; j < connected[end].length; j++) {
					// Push it into the connectedLists[i] array for this wire
					connectedLists[i].push(connected[end][j]);
				}
			}
		}
		// For each connector
		var numOfWires:Number = connectorList.length;
		for (var i:Number = numOfWires; i < (numOfWires + Connector.connectorList.length); i++) {
			// Keep a pointer to this particular connector
			connectorList.push(Connector.connectorList[i - numOfWires]);
			// Push all connectors connected to this connector into non-indexed and indexed lists
			connectedLists[i] = new Array();
			indexedConnectedLists[i] = new Array();
			// For each pin or wire in connectorList[i]'s _connected list, on either end
			var connected:Array = Connector.connectorList[i - numOfWires].connected;
			for (var end:Number = 0; end < 2; end++) {
				// For each component connected to that wire end
				for (var j:Number = 0; j < connected[end].length; j++) {
					// Push it into the indexedConnectedLists[i] array for this wire
					connectedLists[i].push(connected[end][j]);
				}
			}
		}
		
		// Replace the indexedConnectedLists lists with indexes
		for (var i:Number = 0; i < connectorList.length; i++) {
			for (var j:Number = 0; j < connectedLists.length; j++) {
				for (var k:Number = 0; k < connectedLists[j].length; k++) {
					if (connectedLists[j][k] == connectorList[i])
						indexedConnectedLists[j].push(i);
				}
			}
		}
		
		// ================================ MULTI-PASS NET SEARCHING ================================
		var searched:Array = []; // If searched[i] == true then the connectorNames[i] array has been searched
		// Initialise the search variable to all false/unsearched
		for (var i:Number = 0; i < connectorList.length; i++)
			searched[i] = false;
			
		var nets:Array = [];
		
		var passes:Number = 0;
		
		// MIGHT NOT NEED THE WHILE LOOP
		// While there is an unsearched node
		//while (!allSearched(searched)) {
			// Get the next unsearched component index
			for (var nextUnsearched:Number = 0; nextUnsearched < connectorList.length; nextUnsearched++) {
				if (searched[nextUnsearched]) {
					continue;
				}
				passes++;
				// Set searched for this index to be true
				searched[nextUnsearched] = true;
				// We now have the next unsearched index
				var newList:Array = [];
				// For each component in the next unsearched index's list
				for (var i:Number = 0; i < indexedConnectedLists[nextUnsearched].length; i++) {
					// If the component is new, push it into newList
					if (!newList.has(indexedConnectedLists[nextUnsearched][i]))
						newList.push(indexedConnectedLists[nextUnsearched][i]);
				}
				// We now have a list of new indexes to search
				// Search until no new values are found
				var done:Boolean = false;
				while (!done) {
					done = true;
					var tempList:Array = [];
					// For each index in j
					for (var j:Number = 0; j < newList.length; j++) {
						// If it's already been searched, do nothing
						if (searched[newList[j]])
							continue;
						// Set the searched index to be true
						searched[newList[j]] = true;
						// Push any new values it has into the tempList array
						for (var k:Number = 0; k < indexedConnectedLists[newList[j]].length; k++) {
							// If it doesn't already exist in the newList
							if (!newList.has(indexedConnectedLists[newList[j]][k])) {
								// Push it into the tempList
								tempList.push(indexedConnectedLists[newList[j]][k]);
								// There was a new value found, so we're not done yet
								done = false;
							}
						}
					}
					// If we're still not done, add the new indexes to the newList from tempList
					if (!done) {
						// Push all new values of tempList into newList
						for (var n:Number = 0; n < tempList.length; n++) {
							if (!newList.has(tempList[n])) {
								newList.push(tempList[n]);
							}
						}
					} else {
						nets.push(newList);
					}
				}
			}
		//}
		
		// ================================ WIRE REMOVAL ================================
		// Remove the first 'numOfWires' items from these 2 lists
		connectorList.splice(0, numOfWires);
		assignedNets.splice(0, numOfWires);
		
		// Remove items from these arrays if they are less than the numOfWires index, otherwise subtract numOfWires
		for (var i:Number = nets.length - 1; i >= 0; i--) {
			// Remove 0 length nets
			if (nets[i].length == 0) {
				nets.splice(i,1);
				continue;
			}
			for (var j:Number = nets[i].length - 1; j >= 0; j--) {
				// If the index is a wire, remove it
				if (nets[i][j] < numOfWires) {
					nets[i].splice(j,1);
				}
				// Else subtract the number of wires
				else {
					nets[i][j] = nets[i][j] - numOfWires;
				}
			}
		}
		
		// ================================ CREATE ASSIGNED NETS ================================			
		// Could possibly do this during netList creation
		for (var netNum:Number = 0; netNum < nets.length; netNum++) {
			for (var i:Number = 0; i < nets[netNum].length; i++) {
				assignedNets[nets[netNum][i]] = netNum;
			}
		}
		
		// DEBUG PRINT MESSAGES
		/*(passes == 1) ? trace("Generated netlist in " + passes + " pass") : trace("Generated netlist in " + passes + " passes");
		
		var netNum:Number = 0;
		for (var i:Number = 0; i < nets.length; i++) {
			trace("Net " + netNum++ + " has:");
			for (var j:Number = 0; j < nets[i].length; j++) {
				trace(connectorList[nets[i][j]].getName());
			}
		}*/
		
		var netObj:Object = new Object();
		netObj.connectorList = connectorList;
		netObj.nets = nets;
		netObj.assignedNets = assignedNets;
		return netObj;
	}
	
	private static function allSearched(searched:Array) : Boolean {
		var done:Boolean = true;
		for (var i:Number = 0; i < searched.length; i++) {
			if (searched[i] == false)
				done = false;
		}
		return done;
	}

	// Get the logic expression for the current logic circuit
	public static function logicExpression() : String {
		// Generate the required netlist variables
		var netObj:Object = generateNets();
		
		var connectorList:Array = netObj.connectorList;
		var nets:Array = netObj.nets;
		var assignedNets:Array = netObj.assignedNets;
		
		// Search for the out object connector, it should only have 1 connector, then we can simply get it's net from assignedNets
		var varOutputs:Array = []; // Array to store the indexes of the output connectors
		
		for (var i:Number = 0; i < connectorList.length; i++) {
		// If the parent of the connector is of a 'varOutput' Component._type
			if (connectorList[i]._parent.type == "outPort") {
				// Push the finalOutput object into an array
				varOutputs.push(connectorList[i]._parent);
			}
		}
		
		// The logic strings
		var logicStrings:Array;
		
		// For each outPort object
		for (var i:Number = 0; i < varOutputs.length; i++) {
			//logicStrings[i] = new String();
			
			return buildLogicString(varOutputs[i], nets, connectorList, assignedNets)
		}
	}
	
	// Recursive string building function
	private static function buildLogicString(logicGate:MovieClip, nets:Array, connectorList:Array, assignedNets:Array) : String {
		// Returns a logic symbol for a string
		String.prototype.toSymbol = function() : String {
			switch (this.toString()) {
				case "andGate":	return "&";
								break;
				case "orGate" : return "|";
								break;
				case "xorGate": return "^";
								break;
				case "notGate": return "!";
								break;
				case "outPort": return this;
								break;
				case "inPort": return this;
								break;
				default:		break;
			}
		};
		
		var tempString:String = "("; // String of the evaluated logic expression
		var logicType:String = logicGate.type.toSymbol(); // Logic type of the component
		
		// If it's a inPort type, simply return the string of it's name
		if (logicType == "inPort") {
			return logicGate.text;
		// If the current logicType is a NOT operation
		} else if (logicType == "!") {
			tempString += logicType;
		}
		
		// Store all the input connectors of the current logic gate
		var inputConnectors:Array = [];
		// First get the inputs of the current Component object
		for (var i:Number = 0; i < logicGate.connectors.length; i++) {
			if (logicGate.connectors[i].isInput)
				inputConnectors.push(logicGate.connectors[i]);
		}
		
		// For each input connector, find it's net, find the component outputting to that net, pass that component recursively to this function
		for (var i:Number = 0; i < inputConnectors.length; i++) {
			// Find it's net
			var currentNet:Number;
			for (var j:Number = 0; j < connectorList.length; j++) {
				if (inputConnectors[i] == connectorList[j]) {
					currentNet = assignedNets[j];
					break;
				}
			}
			
			// There should only be 1 component outputting to this net
			var outputsCount:Number = 0;
			var outputConnector:Connector;
			for (var j:Number = 0; j < nets[currentNet].length; j++ ) {
				// If there current connector type is a output connector
				if (!connectorList[nets[currentNet][j]].isInput) {
					outputsCount++;
					outputConnector = connectorList[nets[currentNet][j]];
				}
			}
			
			// If there is only one output connector for this net
			if (outputsCount == 1) {							
				// Get the parent logic gate object of this connector
				var nextLogicGate:MovieClip = outputConnector._parent;
				
				// Call this function recursively
				tempString += buildLogicString(nextLogicGate, nets, connectorList, assignedNets);
				
				// Add the corresponding operator from the table, only if the logic gate has 2 or more inputs
				if (inputConnectors.length > 1) {
					// If this isn't the last input connector
					(i != (inputConnectors.length - 1)) ? tempString+=logicType : null;
				}
			} else {
				tempString = "INVALID";
			}
		}
		
		// Add a closing bracket
		tempString += ")";
		return tempString;
	}	
}
