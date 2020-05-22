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

/** 
 * Delegate class 
 * - MTASC friendly 
 * - allows additional parameters when creating the Delegate 
 * 
 * By Philippe from FlashDevelop
 */ 
class Utility.DelegateFD 
{ 
   /** 
    * Create a delegate function 
    * @param target   Objet context 
    * @param handler   Method to call 
    */ 
   public static function create(target:Object, handler:Function) : Function 
   { 
      var func:Function = function() 
      { 
         var context:Function = arguments.callee; 
         var args:Array = arguments.concat(context.initArgs); 
         return context.handler.apply(context.target, args); 
      } 

      // Don't use local references to avoid "Persistent activation object" bug 
      // See: http://timotheegroleau.com/Flash/articles/scope_chain.htm 
      func.target = target; 
      func.handler = handler; 
      func.initArgs = arguments.slice(2); 
      return func; 
   } 
}
