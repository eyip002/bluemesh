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

class Utility.McLib {
	
	private static function McLib() { };

	/**
	* Attach a library item and assimilate it to a given class
	* @param classRef Wanted class
	* @param target   Parent MovieClip
	* @param id       Library ID
	* @param name     Instance name
	* @param depth     Instance depth
	* @param params    Instance parameters
	* @return Reference to the created object
	*/
	static public function attachWithClass(	classRef:Function,
											target:MovieClip,
											id:String,
											name:String,
											depth:Number,
											params:Object
										  ) : MovieClip {
		var mc:MovieClip = target.attachMovie(id, name, depth, params);
		mc.__proto__ = classRef.prototype;
		classRef.apply(mc);
		return mc;
   }
   
   
	/**
	* Creates a Class extends MovieClip on the stage in given context
	* @param   classRef Class to create
	* @param   target Scope where to create
	* @param   name Instance name
	* @param   depth Instance depth
	* @param   params Initialize paramters
	* @return Reference to the created object
	* @author maZe - www.web-specials.net
	*/
	static public function createWithClass(	classRef:Function,
											target:MovieClip,
											name:String,
											depth:Number,
											params:Object
										  ) : MovieClip {
		var mc:MovieClip = target.createEmptyMovieClip(name, depth);

		mc.__proto__ = classRef.prototype;
		if (params != undefined) {	//Filling with given parameters like attachMovie
			for (var i:Object in params) {
				mc[i] = params[i];
			}
		}
		classRef.apply(mc);
		return mc;
	}
	
	static public function copy(obj:Object) : Object {
		var variableCopy:Object = new obj.__proto__.constructor(obj);
		
		for (var i:Object in obj) {
			if(typeof obj[i] == "object") {
				variableCopy[i] = Utility.McLib.copy(obj[i]);
			} else {
				variableCopy[i] = obj[i];
			}
		}
		return variableCopy;
	}
} 