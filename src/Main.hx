package ;

// TODO: Fix issue with buttons when clicked and dragged off
// TODO: Fix issue with canvas dragging when dragged over buttons
// TODO: Make button so mouseUp only works when it had a mouse down event

// UI Elements
import ui.Button;
import ui.Toolbox;
import ui.Canvas;
import ui.PaletteBox;
import ui.Cursor;
import ui.BrushPopup;
import ui.BitmapFont;
import ui.TouchManager;

// Graphical Helpers
import graphics.BrushFactory;
import graphics.PaletteFactory;
import graphics.Color;

// Tools
import tools.Pencil;
import tools.Move;
import tools.Picker;
import tools.Filler;

// Iterators
import util.LineIter;

// Other Utils
import util.Utils;
import Registry;

// Libraries
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.system.System;
import nme.ui.Keyboard;
import nme.ui.Mouse;
import nme.ui.Multitouch;

import nme.filesystem.File;

class Main extends Sprite {

  private var buttons:Array<Button>;
  private var toolbox:Toolbox;
  private var paletteBox:PaletteBox;

  private var brushFactory:BrushFactory;

  private var canvas:Canvas;

  private var cursor:Cursor;

  private var brushPopup:BrushPopup;

  private var pencil:Pencil;
  private var move:Move;
  private var picker:Picker;
  private var filler:Filler;

  private var font:BitmapFont;

  // TouchEvent stuff
  private var supportsTouchEvents:Bool;

  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    addEventListener(Event.ENTER_FRAME, enterFrame);

    Registry.stageWidth = stage.stageWidth;
    Registry.stageHeight = stage.stageHeight;

    Registry.touchManager = new TouchManager();
    supportsTouchEvents = Multitouch.supportsTouchEvents; 

    //
    // Add Events for Stage
    //
    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);

    if (supportsTouchEvents) {
      stage.addEventListener(TouchEvent.TOUCH_BEGIN, Registry.touchManager.onTouchBegin);
      stage.addEventListener(TouchEvent.TOUCH_MOVE, Registry.touchManager.onTouchMove);
      stage.addEventListener(TouchEvent.TOUCH_END, Registry.touchManager.onTouchEnd);

      stage.addEventListener(TouchEvent.TOUCH_MOVE, stageTouchMove);
    }


    var halfHeight = Math.floor(stage.stageHeight / 2);
    var toolboxWidth = 200;

    brushFactory = new BrushFactory("brushes.png", 7, 7, 0xFF00FF);

    // 
    // Setup Tools
    //
    var revert = function() {
      toolbox.clickButtonByName(canvas.previousTool.name);
    };
    pencil = new Pencil();
    move = new Move(function() {
      revert();
      canvas.previousTool = move;
    });
    picker = new Picker(function(color:Int):Void {
      setCanvasBrushColor(color);
      revert();
      canvas.previousTool = picker;
    });
    filler = new Filler();

    //
    // Setup Canvas
    //
    canvas = new Canvas(64, 64, brushFactory, pencil);
    canvas.originalPos = new Point(toolboxWidth, 0);
    canvas.moveTo(
        Math.floor(200 + ((stage.stageWidth - 200) / 2) - canvas.uWidth / 2), 
        Math.floor(stage.stageHeight / 2 - canvas.uHeight / 2)
    );

    addChild(canvas);

    font = new BitmapFont("profont_2x.png", 16, 8);
    font.drawTextBitmap(canvas.getCanvas(), 10, 10, "ABCDE");


    //
    // Setup Palette Box
    //
    paletteBox = new PaletteBox(toolboxWidth, halfHeight - 50, 3, 3, setCanvasBrushColor);
    paletteBox.x = 0;
    paletteBox.y = halfHeight + 50;

    var paletteFactory = new PaletteFactory();
    paletteFactory.load("colors.dat");

    for (color in paletteFactory.getColors()) {
      paletteBox.addColor(color);
    }

    addChild(paletteBox);


    //
    // Popup Box
    //
    brushPopup = new BrushPopup(400, 300, brushFactory, function(picked:Int):Void {
      brushFactory.changeBrush(picked);
      cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
    });


    //
    // Setup Toolbox
    //
    toolbox = new Toolbox(toolboxWidth, halfHeight + 50,   3, 4,   4);
    toolbox.x = 0;
    toolbox.y = 0;

    toolbox.setTilesheet("toolbox.png", 4, 4, 0xFF00FF);
    var buttons = [
      ['pencil', function(button):Void { 
        canvas.currentTool = pencil; 
      }, pencil.imageIndex, 1,    true],
      ['move', function(button):Void { 
        move.revert = button.state == Button.CLICKED;
        canvas.previousTool = canvas.currentTool;
        canvas.currentTool = move; 
      }, move.imageIndex,   1,    null],
      ['picker', function(button):Void { 
        canvas.previousTool = canvas.currentTool;
        canvas.currentTool = picker; 
      }, picker.imageIndex, 1,    null],
      ['filler', function(button):Void {
        canvas.currentTool = filler;
      }, filler.imageIndex, 1,    null],
      ['popup', function(button):Void {
        brushPopup.popup(100, 100);
      }, 9,                 null, null],
      ['clear', function(button):Void {
        canvas.canvasModified();
        canvas.clearCanvas();
      }, 8,                 null, null],
      ['undo', function(button):Void {
        canvas.undoStep();
      }, 10,                null, null],
      ['redo', function(button):Void {
        canvas.redoStep();
      }, 11,                null, null],
      ['zoomin', function(button):Void {
        canvas.changeZoom(2);
        cursor.changeZoom(Math.floor(canvas.zoom));
      }, 6,                 null, null],
      ['zoomout', function(button):Void {
        canvas.changeZoom(0.5);
        cursor.changeZoom(Math.floor(canvas.zoom));
      }, 7,                 null, null],
      ['palup', function(button) {
        canvas.quickView();
        //paletteBox.scroll(-1);
      }, 4,                 null, null]/*,
      ['paldown', function(button) {
        paletteBox.scroll(1);
        // Stuff for FS browsing
        //trace(sys.FileSystem.readDirectory("/mnt/sdcard"));
        //trace(sys.FileSystem.stat("/mnt/sdcard/test.png"));
        //sys.FileSystem.rename("/mnt/sdcard/test.png", "/mnt/sdcard/test2.png");
        //trace(sys.FileSystem.readDirectory("/mnt/sdcard"));
        //trace(File.documentsDirectory.nativePath);
        //trace(File.documentsDirectory.url);
        //trace(File.userDirectory.nativePath);
        //trace(File.userDirectory.url);
        //trace(File.applicationStorageDirectory.nativePath);
        //trace(File.applicationStorageDirectory.url);
#if (linux || android)
        var tempBytes = canvas.getCanvas().encode('png');
#if linux 
        var f = sys.io.File.write(File.userDirectory.nativePath + '/knitter.png', true); 
#else if android
        var f = sys.io.File.write(File.documentsDirectory.nativePath + '/knitter.png', true); 
#end
        f.writeString(tempBytes.asString());
        f.close();
#end
      }, 5,                 null, null]
      */
    ];

    for (button in buttons) {
      toolbox.addButton(button[0], button[1], button[2], button[3], button[4]);
    }

    addChild(toolbox);

    // Put Popup Box on Top
    addChild(brushPopup);

    //
    // Setup Cursor
    //
    cursor = new Cursor();
    cursor.addTypeCursor("canvas", brushFactory.getBrushImage(), true);
    addChild(cursor);

    //toolbox.clickButton(6);


    canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
    canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);

  }

  private function touchTouchBegin(event:MouseEvent) {
    trace("touch fired");
  }

  private function canvasMouseOver(event:MouseEvent) {
    cursor.setCursor("canvas");
  }

  private function canvasMouseOut(event:MouseEvent) {
    cursor.setCursor("default");
  }

  private function setCanvasBrushColor(color:Int):Void {
    brushFactory.changeColor(color);
    cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
  }
  
  private function update():Void {

  }

  private function drawLine():Void {
    for (p in (new LineIter(10, 10, 100, 80))) {
      canvas.drawDot(p[0], p[1]);
    }
  }

  private function paletteBoxScrollUp():Void {
  }

  private function drawRedCircle():Void { drawCircle(0xFF0000); }
  private function drawGreenCircle():Void { drawCircle(0x00FF00); }
  private function drawBlueCircle():Void { drawCircle(0x0000FF); }
  private function drawCircle(color:Int):Void {
    var gfx = this.graphics;
    var tempX = Math.random() * stage.stageWidth;
    var tempY = Math.random() * (stage.stageHeight - 64);
    gfx.beginFill(color);
    gfx.drawCircle(tempX, tempY, 30);
    gfx.endFill();
  }


  // -------------------------------------------------- 
  //                  Event Handlers
  // -------------------------------------------------- 

  private function addedToStage(event:Event):Void {
    construct();
  }

  private function enterFrame(event:Event):Void {
    update();
  }

  //
  // Mouse Events
  //
  private function stageMouseMove(event:MouseEvent):Void {
    cursor.update(event.stageX, event.stageY);
  }

  private function stageMouseUp(event:MouseEvent):Void {
  }
  
  private function stageMouseDown(event:MouseEvent):Void {
  }

  //
  // Touch Events
  //
  private function stageTouchBegin(event:TouchEvent):Void {
  }

  private function stageTouchMove(event:TouchEvent):Void {
    if (Registry.touchManager.touchCount == 2) {
      canvas.changeZoom((Registry.touchManager.newScale - 1) / Math.sqrt(canvas.zoom) + 1);
      cursor.changeZoom(Math.floor(canvas.zoom));
      canvas.moveBy(Registry.touchManager.translateX, Registry.touchManager.translateY);
    }
  }

  private function stageTouchEnd(event:TouchEvent):Void {
  }

  private function stageKeyDown(event:KeyboardEvent):Void {
    var keyCode = event.keyCode;
#if (cpp || neko)
    if (event.keyCode >= 97 && event.keyCode <= 123) {
      keyCode -= 32;
    }
#end
    if (keyCode == Keyboard.ESCAPE) {
      System.exit(0);
    }
    else if (keyCode == Keyboard.V) {
      drawBlueCircle();
    }
    else if (keyCode == Keyboard.LEFT) {
      canvas.x += 10 * canvas.zoom;
    }
    else if (keyCode == Keyboard.RIGHT) {
      canvas.x -= 10 * canvas.zoom;
    }
    else if (keyCode == Keyboard.UP) {
      canvas.y += 10 * canvas.zoom;
    }
    else if (keyCode == Keyboard.DOWN) {
      canvas.y -= 10 * canvas.zoom;
    }
    else if (keyCode == Keyboard.EQUAL) {
      toolbox.clickButtonByName("zoomin");
    }
    else if (keyCode == Keyboard.MINUS) {
      toolbox.clickButtonByName("zoomout");
    }
  }
}

