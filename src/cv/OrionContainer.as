﻿/**
* Orion ©2009 Gabriel Mariani. February 6th, 2009
* Visit http://blog.coursevector.com/orion for documentation, updates and more free code.
*
*
* Copyright (c) 2009 Gabriel Mariani
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package cv {
	
	import cv.orion.ParticleVO;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * OrionContainer takes a movieclip and animates the children inside
	 * of it as if they were particles. Does not add any new particles to the system.
	 * 
	 * Also any changes to the dimensions or position of the emitter are ignored.
     */
	public class OrionContainer extends Orion {
		
		/**
		 * This offset is used by the BitmapRenderer to fix render issues.
		 * This is set automatically by assignParticles(), but is public to
		 * allow for custom alignment if necessary.
		 */
		public var offSet:Point = new Point();
		
		private var _spriteTarget:DisplayObjectContainer;
		
		/**
		 * The constructor for OrionContainer is slightly different from Orion. You cannot specify an output class
		 * becuase it is not used by OrionContainer. No new particles are created so there is nothing to output. Secondly
		 * you cannot specify framecaching becuase again, no new particles are created while this runs. 
		 * 
		 * When the constructor runs, the canvas is automatically set to the stage dimensions (if available) and 
		 * corrects for the target's position.
		 * 
		 * In debug mode, the emitter is positioned according to the coordinates of the target's parent. For
		 * the emitter to be positioned accurately, OrionContainer must be attached to the same DisplayObject
		 * as the target. This is only for the debug lines to be accurate, it's not required for anything else.
		 * 
		 * @param	target<DisplayObject> The display object to use.
		 * @param	assignChildren<Boolean> Whether to add the target or the children inside the target.
		 * @param	config	Here you can pass in a <code>configuration</code> object. A <code>configuration</code> object is generated by a 
		 * preset or you can write one by hand. Each <code>configuration</code> object can contain an <code>effectFilters</code> array, an
		 * <code>edgeFilter</code> object, and a <code>settings</code> object. The <code>settings</code> object can contain all the same properties that
		 * modifying the <code>settings</code> property directly allows.<br/><br/>If no config is passed, OrionContainer will automatically pause
		 * to allow the settings object to be configured before starting.
		 */
		public function OrionContainer(target:DisplayObjectContainer, config:Object = null) {
			super(Sprite, null, config);
			
			var b:Rectangle = target.getBounds(target.parent);
			offSet.x = b.x;
			offSet.y = b.y;
			_emitter.width = b.width;
			_emitter.height = b.height;
			_emitter.x = b.x;
			_emitter.y = b.y;
			_spriteTarget = target;
			
			if(config == null) {
				paused = true;
			} else {
				applySettings();
			}
			
			// Init canvas if reference to stage is available
			if(target.stage) {
				var pt:Point = target.globalToLocal(new Point());
				canvas = new Rectangle(pt.x + offSet.x, pt.y + offSet.y, target.stage.stageWidth, target.stage.stageHeight);
			}
		}
		
		/**
		 * The useFrameCaching property is disabled with this emitter.
		 */
		override public function get useFrameCaching():Boolean { return _useFrameCaching; }
		/** @private **/
		override public function set useFrameCaching(value:Boolean):void {
			//
		}
		
		/**
		 * Gets the height of the emitter, setting is disabled.
		 */
		override public function get height():Number { return _emitter.height; }
		/** @private **/
		override public function set height(value:Number):void {
			//
		}
		
		/**
         * The SpriteTarget property is OrionContainer's equivalent of SpriteClass.
         * This sets the target to use as particles.
		 */
		public function get spriteTarget():DisplayObjectContainer { return _spriteTarget; }
		/** @private **/
		public function set spriteTarget(value:DisplayObjectContainer):void {
			removeAllParticles();
			_spriteTarget = value;
			applySettings();
		}
		
		/**
         * The spriteClass property is disabled with this emitter.
		 */
		override public function get spriteClass():Class { return Sprite; }
		/** @private **/
		override public function set spriteClass(value:Class):void {
			//
		}
		
		/**
		 * Gets the width of the emitter, setting is disabled.
		 */
		override public function get width():Number { return _emitter.width; }
		/** @private **/
		override public function set width(value:Number):void {
			//
			if (hasEventListener(Event.RESIZE)) dispatchEvent(_eventResize);
		}
		
		/**
		 * Gets the x position of the emitter, setting is disabled.
		 * 
		 * @see Orion#getCoordinate()
		 * @see Orion#y
		 */
		override public function get x():Number { return _emitter.x; }
		/** @private **/
		override public function set x(value:Number):void { }
		
		/**
		 * Gets the y position of the emitter, setting is disabled.
		 * 
		 * @see Orion#getCoordinate()
		 * @see Orion#x
		 */
		override public function get y():Number { return _emitter.y; }
		/** @private **/
		override public function set y(value:Number):void {	}
		
		public function applySettings():void {
			var i:int = DisplayObjectContainer(_spriteTarget).numChildren;
			var d:DisplayObject, p:ParticleVO;
			while (i--) {
				d = DisplayObjectContainer(_spriteTarget).getChildAt(i);
				p = new ParticleVO();
				p.target = d;
				p.velocity = new Point();
				d.blendMode = cacheBlendMode;
				d.cacheAsBitmap = useCacheAsBitmap;
				resetParticle(p);
			}
		}
		
		/**
		 * Stops Orion from creating new particles.
		 * 
		 * @param	point	Where to position the particle
		 */
		override public function emit(point:Point = null):void { }
	}
}