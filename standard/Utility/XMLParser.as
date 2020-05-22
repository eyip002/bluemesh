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
VERSION: 4.7
DATE: 2/14/2008
DESCRIPTION: 
	 This class provides an easy way to load and/or send an XML file and parse the data into a format that's simple 
	 to work with. Every node becomes an array with the same name. All attributes are also easily accessible because 
	 they become properties with the same name. So for example, if this is your XML:
	 
		<Resources>
			<Book name="Mary Poppins" ISDN="1122563" />
			<Book name="The Bible" ISDN="333777" />
			<Novel name="The Screwtape Letters" ISDN="257896">
				<Description>This is an interesting perspective</Description>
			</Novel>
		</Resources>
	 
	 Then you could access the first book's ISDN with:
	 
	 	Book[0].ISDN
	 
	 The value of a node (like the text between the <Description> and </Description> tags above can
	 be accessed using the "value" property, like so:
	 
	 	Novel[0].Description[0].value
	 
	 Just remember that all nodes become arrays even if there's only one node, and attributes become properties. 
	 You can obviously loop through the arrays too which is very useful. The root node is ignored for efficiency 
	 (less code for you to write) unless you set the keepRootNode_bol to true.

EXAMPLE: 
	To simply load a "myDocument.xml" document and parse the data into ActionScript-friendly values, do:
	
		import gs.dataTransfer.XMLParser;
		var parsedObject:Object; //This will hold the parsed xml data (once the XML loads and gets parsed).
		XMLParser.load("myDocument.xml", onFinish);
		function onFinish($success, $parsedObject, $xml) { //This function gets called when the XML gets parsed.
			if ($success) {
				parsedObject = $parsedObject;
				trace("The first book is: "+$parsedObject.Book[0].name);
			}
		}
		
	Or to send an object to the server in XML format (remember, each element in an array becomes a node and all 
	object properties become node attributes) and load the results back into an ActionScript-friendly format, do:
	
		import gs.dataTransfer.XMLParser;
		//Create an object to send an populate it with values...
		var toSend_obj = new Object();
		toSend_obj.name = "Test Name";
		toSend_obj.Book = new Array();
		toSend_obj.Book.push({title:"Mary Poppins", ISDN:"125486523"});
		toSend_obj.Book.push({title:"The Bible", ISDN:"25478866998"});
		//Now send the data and load the results from the server into the response_obj...
		var parsedObject:Object; //We'll use this to hold the parsed xml response.
		XMLParser.sendAndLoad(toSend_obj, "http://www.myDomain.com/myScript.php", onFinish);
		function onFinish($success, $parsedObject, $xml) {
			if ($success) {
				trace("The server responded with this XML: "+$xml);
				trace("The server's response was translated into this ActionScript object: "+$parsedObject);
			}
		}
		
		In the example above, the server would receive the following XML document:
		
		<XML name="Test Name">
			<Book ISDN="125486523" title="Mary Poppins" />
			<Book ISDN="25478866998" title="The Bible" />
		</XML>
	
NOTES:
	- It is case sensitive, so if you run into problems, check that.
	- The value of any text node can be accessed with the "value" property as mentioned above.
	- A valid XML document requires a single root element, so in order to consolidate things,
	  That root will be ignored in the resulting arrays. So if your root element is <Library>
	  and it has <Book> nodes, you don't have to access them with Library[0].Book[0]. You can 
	  just do Book[0].
	- To translate all instances of "\n" in your XML into line breaks, set the parseLineBreaks 
	  argument to true. (see the load() and sendAndLoad() and XMLToObject() methods)
	- You can simply translate an object into XML (without sending it anywhere) using the 
	  XMLParser.objectToXML(my_obj) function which returns an XML instance.
	- Cancel the loading of an XML file using the cancel() method.
		
CODED BY: Jack Doyle, jack@greensock.com
*/



import DelegateFD;

class Utility.XMLParser {
//	static var CLASS_REF:Object = Utility.XMLParser;
	var parse:Function; //Just for backward compatibility. It's essentially an alias pointing to the initLoad() function.
	var loaded_bol:Boolean;
	var keepRootNode_bol:Boolean;
	var parseLineBreaks:Boolean;
	private var _xmlUrl:String;
	private var _onComplete:Function;
	private var _xml:XML;
	private var _results:Object;
	private static var _all:Array;
	
	function XMLParser() {
		parse = initLoad; //Just for backward compatibility. It's essentially an alias pointing to the initLoad() function.
		loaded_bol = false;
		if (_all == undefined) {
			_all = [];
		}
		_all.push(this);
	}
	
	static function load($url:String, $onComplete:Function, $results:Object, $keepRootNode:Boolean, $parseLineBreaks:Boolean):XMLParser {
		var parser_obj : XMLParser = new XMLParser();
		parser_obj.initLoad($url, $onComplete, $results, $keepRootNode, $parseLineBreaks);
		return parser_obj;
	}
	
	static function sendAndLoad($toSend:Object, $url:String, $onComplete:Function, $results:Object, $keepRootNode:Boolean, $parseLineBreaks:Boolean):XMLParser {
		var parser_obj : XMLParser = new XMLParser();
		parser_obj.initSendAndLoad($toSend, $url, $onComplete, $results, $keepRootNode, $parseLineBreaks);
		return parser_obj;
	}
	
	function initLoad($url:String, $onComplete:Function, $results:Object, $keepRootNode:Boolean, $parseLineBreaks:Boolean):Void {
		_results = $results || {};
		_xmlUrl = $url;
		_onComplete = $onComplete;
		this.keepRootNode_bol = $keepRootNode;
		this.parseLineBreaks = $parseLineBreaks;
		_xml = new XML();
		_xml.ignoreWhite = true;
		loaded_bol = false;
		if (_xmlUrl.charAt(0) == "<") {
			this.onData(_xmlUrl);
		} else {
			_xml.onData = Utility.DelegateFD.create(this, this.onData);
			_xml.load(_xmlUrl);
		}
	}
	
	function initSendAndLoad($toSend:Object, $url:String, $onComplete:Function, $results:Object, $keepRootNode:Boolean, $parseLineBreaks:Boolean):Void {
		_results = $results || {};
		_xmlUrl = $url;
		_onComplete = $onComplete;
		this.keepRootNode_bol = $keepRootNode;
		this.parseLineBreaks = $parseLineBreaks;
		var xmlToSend:Object;
		if ($toSend instanceof XML) {
			xmlToSend = $toSend;
		} else {
			xmlToSend = XMLParser.objectToXML($toSend);
		}
		_xml = new XML();
		_xml.ignoreWhite = true;
		_xml.onData = Utility.DelegateFD.create(this, this.onData);
		loaded_bol = false;
		xmlToSend.sendAndLoad(_xmlUrl, _xml);
	}
	
	function onData($xml:String):Void {
		if ($xml == undefined) {
			parseLoadedXML(false);
		} else {
			this._xml.parseXML($xml);
			loaded_bol = true;
			parseLoadedXML(true);
		}
	}
	
	private function parseLoadedXML($success:Boolean):Void {
		if ($success == false) {
			trace("XML FAILED TO LOAD! ("+_xmlUrl+")");
			_onComplete(false);
			return;
		}
		XMLToObject(this._xml, _results, this.keepRootNode_bol, this.parseLineBreaks);
		_onComplete(true, _results, this._xml);
	}
	
	public static function XMLToObject($xml:XML, $results:Object, $keepRootNode:Boolean, $parseLineBreaks:Boolean):Object { //$results is optional - it allows you to define an object to append all the properties/arrays to.
		var x:Object = $xml; //To avoid typing errors
		$results = $results || {};
		var c:Object = x.firstChild; //"c" is for current_node
		var last_node:XMLNode = x.firstChild;
		x.obj = $results; //Allows us to tack on all the arrays and objects to this instance for easy retrieval by the user. If this causes a problem, we could create a public object variable that holds everything, but this simplifies things for the user.
		if ($keepRootNode != true) {
			c = c.firstChild;
			last_node = x.firstChild.lastChild;
			x.firstChild.obj = $results; //Allows us to tack on all the arrays and objects to this instance for easy retrieval by the user. If this causes a problem, we could create a public object variable that holds everything, but this simplifies things for the user.
		}
		while(c != undefined) {
			//We ran into an issue where Flash was creating an extra subnode anytime we had content in a node like <NODE>My Content</NODE>. The tip off is when the nodeName is null and the nodeType is 3 (text).
			if (c.nodeName == null && c.nodeType == 3) {
				c.parentNode.obj.value = clean(c.nodeValue, $parseLineBreaks);
			} else {
				var o:Object = {};
				for (var att:String in c.attributes) {
					o[att] = clean(c.attributes[att], $parseLineBreaks);
				}
				var pn:Object = c.parentNode.obj;
				if (pn[c.nodeName] == undefined) {
					pn[c.nodeName] = [];
				}
				c.obj = o;
				pn[c.nodeName].push(o);
			}
			
			
			if (c.childNodes.length > 0) {
				c = c.childNodes[0];
			} else {
				var next_node:Object = c;
				while(next_node.nextSibling == undefined && next_node.parentNode != undefined) {
					next_node = next_node.parentNode;
				}
				c = next_node.nextSibling;
				if (next_node == last_node) {
					c = undefined;
				}
			}
		}
		return $results;
	}
	
	private static function clean($s:String, $parseLineBreaks:Boolean):Object {
		if (!isNaN(Number($s)) && $s != "") {
			return Number($s);
		} else if ($parseLineBreaks) {
			return $s.split("\\n").join("\n");
		} else {
			return $s;
		}
	}
	
	//Allows us to translate an object (typically with arrays attached to it) back into an XML object. This is useful when we need to send it back to the server or save it somewhere.
	public static function objectToXML($o:Object, $rootNodeName:String):XML {
		if ($rootNodeName == undefined) {
			$rootNodeName = "XML";
		}
		var xml:XML = new XML();
		var n:XMLNode = xml.createElement($rootNodeName);
		var props:Array = [];
		var prop:String, tn:XMLNode;
		for (var p:String in $o) {
			props.push(p);
		}
		for (var p:Number = props.length - 1; p >= 0; p--) { //By default, attributes are looped through in reverse, so we go the opposite way to accommodate for this.
			prop = props[p];
			if (typeof($o[prop]) == "object" && $o[prop].length > 0) { //Means it's an array!
				arrayToNodes($o[prop], n, xml, prop);
			} else if (prop == "value") {
				tn = xml.createTextNode($o.value);
				n.appendChild(tn);
			} else {
				n.attributes[prop] = $o[prop];
			}
		}
		xml.appendChild(n);
		return xml;
	}
	
	//Recursive function that walks through any sub-arrays as well...
	private static function arrayToNodes($ar:Array, $parentNode:XMLNode, $xml:XML, $nodeName:String):Void {
		var chldrn:Array = [];
		var props:Array, prop:String, n:XMLNode, o:Object, i:Number;
		for (i = $ar.length - 1; i >= 0; i--) {
			n = $xml.createElement($nodeName);
			o = $ar[i];
			props = [];
			for (var p:String in o) {
				props.push(p);
			}
			for (var p:Number = props.length - 1; p >= 0; p--) { //By default, attributes are looped through in reverse, so we go the opposite way to accommodate for this.
				prop = props[p];
				if (typeof(o[prop]) == "object" && o[prop].length > 0) { //Means it's an array!
					arrayToNodes(o[prop], n, $xml, prop);
				} else if (prop != "value") {
					n.attributes[prop] = o[prop];
				} else {
					var tn:XMLNode = $xml.createTextNode(o.value);
					n.appendChild(tn);
				}
			}
			chldrn.push(n);
		}
		for (i = chldrn.length - 1; i >= 0; i--) {
			$parentNode.appendChild(chldrn[i]);
		}
	}
	
	public function cancel():Void {
		_xml.onData = null;
	}
	
	public function destroy():Void {
		cancel();
		delete _xml;
		for (var i:Number = _all.length - 1; i >= 0; i--) {
			if (this == _all[i]) {
				_all.splice(i, 1);
			}
		}
		destroyInstance(this);
	}
	
	static function destroyInstance($i:XMLParser):Void {
		delete $i;
	}
	
//---- GETTERS / SETTERS --------------------------------------------------------------------
	static function get active_bol() : Boolean {
		if (_all.length > 0) {
			return true;
		} else {
			return false;
		}
	}
	
	function get percentLoaded_num():Number {
		return (this.bytesLoaded / this.bytesTotal) * 100;
	}
	
	function get xml() : XML {
		return _xml;
	}
	
	function get bytesLoaded() : Number {
		return _xml.getBytesLoaded() || 0;
	}
	
	function get bytesTotal() : Number {
		if (loaded_bol) {
			return _xml.getBytesTotal() || 0;
		} else {
			return _xml.getBytesTotal() || 1024; //We should report back some size for preloaders so that if they do something like (my_mc.getBytesLoaded() + myParser_obj.bytesLoaded) / (my_mc.getBytesTotal() + myParser_obj.bytesTotal) because it might look like it's 100% loaded even though it hasn't started yet!
		}
		
	}
	
}