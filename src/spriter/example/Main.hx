package spriter.example;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Keyboard;
import openfl.Assets;
import openfl.display.FPS;
import spriter.definitions.ScmlObject;
import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.BitmapLibrary;
import spriter.library.SpriterLibrary;
import spriter.library.TilelayerLibrary;

/**
 * To test : 
 * Press INSERT key to add an entity
 * Press A key to change animation
 * Press SPACE key to change character mapping
 * @author Loudo
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	public var engine:SpriterEngine;
	public var scml:ScmlObject;
	
	public var len:Int = 1;//number of spriter entity
	
	public var currentAnim:Int = 0;
	public var currentCharMap:Int = -1;
	public var anims:Array<String> = ['normal', 'instant', 'bone'];//TODO get automatically
	public var charMaps:Array<String> = ['gold', 'circle']; //TODO get automatically
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		
		var fps:FPS = new FPS();
		addChild(fps);
		
		/*
		 * BLOCK 1 : Simple bitmap library
		 */
		/*
		var spriterRoot:Sprite = new Sprite();
		
		var lib:SpriterLibrary = new SpriterLibrary('assets/ugly/');
		
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly_b6_1.scml'), lib, spriterRoot );

		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 10),  100 * (Std.int(i / 10) % 6));
		}
		*/
		/*
		 * END BLOCK 1
		 */
		/*
		 * BLOCK 2 : tilelayer library
		 */
		
		var spriterRoot:Sprite = new Sprite();
		
		var lib:TilelayerLibrary = new TilelayerLibrary('assets/ugly/ugly.xml' , 'assets/ugly/ugly.png');
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly_b6_1.scml'), lib, spriterRoot );
		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 10),  100 * (Std.int(i / 10) % 6));
		}
		
		/*
		 * END BLOCK 2
		 */
		/*
		 * BLOCK 3 : use BitmapLibrary
		 */
		/*
		var canvas:BitmapData = new BitmapData(800, 480);
		var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);
		
		var lib:BitmapLibrary = new BitmapLibrary('assets/ugly/', canvas);
		
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly_b6_1.scml'), lib, null );
		
		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 10),  100 * (Std.int(i / 10) % 6));
		}
		*/
		/*
		 * END BLOCK 3
		 */
		
		
		addChild(spriterRoot);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		
	}
	private function onKey(e:KeyboardEvent):Void
	{
		switch(e.keyCode) {
			case Keyboard.SPACE:
				/*
				 * Apply character map by name:
				 */
				if (currentCharMap + 1 < charMaps.length) {
					engine.getEntity('lib_1').applyCharacterMap(charMaps[++currentCharMap], false);
				}else {
					//TODO reinit
				}
			case Keyboard.A:
				/*
				 * Change animation by name :
				 */
				if (currentAnim + 1 < anims.length) {
					engine.getEntityAt(0).playAnim(anims[++currentAnim]);
				}else {
					currentAnim = 0;
					engine.getEntityAt(0).playAnim(anims[currentAnim]);
				}
			case Keyboard.INSERT:
				len++;
				/*
				 * Add new entity
				 */
				engine.addEntity('lib_' + len,  100 * ((len - 1) % 10),   100 * (Std.int((len - 1) / 10) % 6));
			case Keyboard.DELETE:
				/*
				 * Remove new entity
				 */
				engine.removeEntityAt(0);
			case Keyboard.S:
				/*
				 *Swap child
				 */
				engine.swapAt(0, 1);
		}
	}
	
	private function onEnterFrame(e:Event):Void
	{
		engine.update();
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
