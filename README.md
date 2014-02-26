Spriter Example
=============

Example for Spriter Haxe Engine : 
https://github.com/loudoweb/SpriterHaxeEngine


Install it:

``haxelib install SpriterHaxeEngine``

Configure it:

```as3
//set the root canvas where to add all the animations
var canvas:BitmapData = new BitmapData(800, 480);
var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);

//you can use a different library to feet your needs. This one use BitmapData.copypixels() and BitmapData.draw()
var lib:BitmapLibrary = new BitmapLibrary('assets/', canvas);

//here is the engine : it will update all your Spriter's entities
engine = new SpriterEngine(Assets.getText('assets/test.scml'), lib, null );
		
//to add and entity
engine.addEntity('entityName', x,  y);

//set the "run" animation of the entity at z-order 0
engine.getEntity(0).playAnim('run');

//apply the "gun" map of the entity at z-order 0
engine.getEntity(0).applyCharacterMap('gun', true);


//update on enter frame
engine.update();
```
 