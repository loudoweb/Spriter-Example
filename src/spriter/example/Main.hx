package spriter.example;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import flash.ui.Keyboard;
import openfl.Assets;
import openfl.display.FPS;
import spriter.definitions.Quadrilateral;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.BitmapLibrary;
import spriter.library.SpriterLibrary;
import spriter.library.TilelayerLibrary;
import spriter.macros.SpriterMacros;
import spriter.vars.Variable;

/**
 * To test : 
 * Press INSERT key to add an entity
 * Press A key to change animation
 * Press M key to change character mapping
 * Press DEL key to remove
 * Press SPACE to pause
 * Press Z to play an animation stack
 * Press S to swap index of 2 spriters
 * Press P to change playback speed
 * @author Loudo
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	var engine:SpriterEngine;
	var scml:ScmlObject;
	
	var len:Int = 1;//number of spriter entity
	var line:Sprite;
	var boxAndPoints:Sprite;
	
	var currentAnim:Int = 0;
	var currentCharMap:Int = -1;
	
	var entities:Array<String>;
	var anims:Array<String>;
	var charMaps:Array<String>;
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		//stats
		#if (!stats || flash)
		var fps:FPS = new FPS();
		addChild(fps);
		#end
		
		SpriterMacros.texturePackerChecker('assets/ugly/ugly.xml');
		
		addControls();
		
		
		boxAndPoints = new Sprite();
		
		
		createTilelayer(null);
		
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		// Focus gained/lost monitoring
		#if desktop
		stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		stage.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		#else
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		#end
	}
	
	/* Spriter engine handler stuff */
	
	private function onKey(e:KeyboardEvent):Void
	{
		switch(e.keyCode) {
			case Keyboard.M:
				/*
				 * Apply character map by name:
				 */
				if (currentCharMap + 1 < charMaps.length) {
					engine.getEntity('lib_1').applyCharacterMap(charMaps[++currentCharMap], false);
				}else {
					currentCharMap = -1;
					engine.getEntity('lib_1').applyCharacterMap('', true);
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
			case Keyboard.Z:
				/*
				 * Play a stack o animations with callback :
				 */
				engine.getEntityAt(0).playAnimsStack(anims, handlePause);
			case Keyboard.INSERT:
				len++;
				/*
				 * Add new entity
				 */
				engine.addEntity('lib_' + len,  100 * ((len - 1) % 8),   100 * (Std.int((len - 1) / 8) % 6));
			case Keyboard.DELETE:
				/*
				 * Remove entity
				 */
				engine.removeEntityAt(0);
			case Keyboard.S:
				/*
				 *Swap child
				 */
				engine.swapAt(0, 1);
			case Keyboard.C:
				/*
				 * Change animation with callback :
				 */
				engine.getEntityAt(0).playAnim(anims[0], handleNextAnim);
			case Keyboard.SPACE:
				/*
				 * Pause/Unpause Engine
				 */
				if (engine.paused) {
					onFocus(null);
				}else {
					onFocusLost(null);
				}
			case Keyboard.P:
				/*
				 * Change playbackspeed :
				 */
				engine.getEntityAt(0).playbackSpeed = 2;
		}
	}
	
	private function handleNextAnim(s:Spriter, entity:String, anim:String):Void
	{
		trace(s.spriterName, entity, anim);
		if (currentAnim + 1 >= anims.length)
			currentAnim = -1;
		s.playAnim(anims[++currentAnim], handleNextAnim);
	}
	
	private function handlePause(s:Spriter, entity:String, anim:String):Void
	{
		s.paused = true;
	}
	
	private function onEnterFrame(e:Event):Void
	{
		engine.update();
		
		var points:Array<SpatialInfo> = engine.getEntityAt(0).getPoints();
		var boxes:Array<Quadrilateral> = engine.getEntityAt(0).getBoxes();
		boxAndPoints.graphics.clear();
		for (box in boxes)
		{
			boxAndPoints.graphics.beginFill(0x00ff00);
			boxAndPoints.graphics.moveTo(box.p1.x, box.p1.y+30);//+30 here because of spriterRoot position
			boxAndPoints.graphics.lineTo(box.p2.x, box.p2.y+30);
			boxAndPoints.graphics.lineTo(box.p3.x, box.p3.y+30);
			boxAndPoints.graphics.lineTo(box.p4.x, box.p4.y+30);
			boxAndPoints.graphics.lineTo(box.p1.x, box.p1.y+30);
			boxAndPoints.graphics.endFill();
		}
		for (point in points)
		{
			
			boxAndPoints.graphics.beginFill(0xff0000);
			boxAndPoints.graphics.drawCircle(point.x,point.y+30, 4);
			boxAndPoints.graphics.endFill();
		}
	}
	private function onFocusLost(e:Event):Void
	{
		if(!engine.paused){
			stage.frameRate = 10;
			engine.pause();
		}
	}
	private function onFocus(e:Event):Void
	{
		if(engine.paused){
			stage.frameRate = engine.framerate;
			engine.unpause();
		}
	}
	
	/* Creation stuff */
	function createBitmap(e:MouseEvent):Void
	{
		
		if (engine != null)
			engine.destroy();
		len = 1;
		line.x = 470;
		/*
		 * Simple bitmap library
		 */
		
		var spriterRoot:Sprite = new Sprite();
		spriterRoot.y = 30;
		var lib:SpriterLibrary = new SpriterLibrary('assets/ugly/');
		
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly.scml'), lib, spriterRoot );
		entities =  engine.scml.getEntitiesName();
		anims = engine.scml.getAnimationsName(entities[0]);
		charMaps = engine.scml.getCharMaps(entities[0]);

		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 8),  100 * (Std.int(i / 8) % 6));
		}
		addChild(spriterRoot);
		addChild(boxAndPoints);
		
		engine.getEntityAt(0).scml.tagCallback = tagCallback;
		engine.getEntityAt(0).scml.varChangeCallback = varCallback;
	}
	function createTilelayer(e:MouseEvent):Void
	{
		if (engine != null)
			engine.destroy();
		len = 1;
		line.x = 560;
		/*
		 * tilelayer library
		 */
		
		var spriterRoot:Sprite = new Sprite();
		spriterRoot.y = 30;
		var lib:TilelayerLibrary = new TilelayerLibrary('assets/ugly/ugly.xml' , 'assets/ugly/ugly.png');
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly.scml'), lib, spriterRoot );
		entities =  engine.scml.getEntitiesName();
		anims = engine.scml.getAnimationsName(entities[0]);
		charMaps = engine.scml.getCharMaps(entities[0]);
		
		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 8),  100 * (Std.int(i / 8) % 6));
		}
		addChild(spriterRoot);
		addChild(boxAndPoints);
		
		engine.getEntityAt(0).scml.tagCallback = tagCallback;
		engine.getEntityAt(0).scml.varChangeCallback = varCallback;
	}
	function createCopypixels(e:MouseEvent):Void
	{
		if (engine != null)
			engine.destroy();
		len = 1;
		line.x = 630;
		/*
		 *  use BitmapLibrary
		 */
		
		var canvas:BitmapData = new BitmapData(900, 470);
		var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);
		spriterRoot.y = 30;
		var lib:BitmapLibrary = new BitmapLibrary('assets/ugly/', canvas);
		
		engine = new SpriterEngine(Assets.getText('assets/ugly/ugly.scml'), lib, null );
		entities =  engine.scml.getEntitiesName();
		anims = engine.scml.getAnimationsName(entities[0]);
		charMaps = engine.scml.getCharMaps(entities[0]);
		
		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1),  75 * (i % 8),  100 * (Std.int(i / 8) % 6));
		}
		addChild(spriterRoot);
		addChild(boxAndPoints);
		
		engine.getEntityAt(0).scml.tagCallback = tagCallback;
		engine.getEntityAt(0).scml.varChangeCallback = varCallback;
	}
	/**
	 * Each time a tag is dispatched
	 * @param	tag name
	 */
	public function tagCallback(tag:String):Void
	{
		trace("tag",tag);
	}
	/**
	 * Each time a variable value changes.
	 * @param	variable
	 */
	public function varCallback(variable:Variable<Dynamic>):Void
	{
		trace("var", variable.toString());
	}
	
	function addControls():Void
	{
		var txt1:TextField = new TextField();
		txt1.text = 'Simple Bitmap';
		txt1.height = 20;
		txt1.width = 85;
		var btn1:Sprite = new Sprite();
		btn1.buttonMode = true;
		btn1.mouseChildren = false;
		btn1.addEventListener(MouseEvent.CLICK, createBitmap);
		btn1.addChild(txt1);
		btn1.x = 470;
		btn1.y = 10;
		addChild(btn1);
		//2
		var txt2:TextField = new TextField();
		txt2.text = 'Tilelayer';
		txt2.height = 20;
		txt2.width = 85;
		var btn2:Sprite = new Sprite();
		btn2.buttonMode = true;
		btn2.mouseChildren = false;
		btn2.addEventListener(MouseEvent.CLICK, createTilelayer);
		btn2.addChild(txt2);
		btn2.x = 560;
		btn2.y = 10;
		addChild(btn2);
		//3
		var txt3:TextField = new TextField();
		txt3.text = 'Bitmap copypixels';
		txt3.height = 20;
		txt3.width = 100;
		var btn3:Sprite = new Sprite();
		btn3.buttonMode = true;
		btn3.mouseChildren = false;
		btn3.addEventListener(MouseEvent.CLICK, createCopypixels);
		btn3.addChild(txt3);
		btn3.x = 650;
		btn3.y = 10;
		addChild(btn3);
		//line
		line = new Sprite();
		line.graphics.beginFill(0x000000);
		line.graphics.drawRect(0, 0, 50, 4);
		line.graphics.endFill();
		addChild(line);
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
