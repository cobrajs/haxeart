package ;

// UI Elements
import ui.Button;
import ui.Toolbox;
import ui.Canvas;
import ui.PaletteBox;
import ui.Cursor;
import ui.BrushPopup;
import ui.BitmapFont;

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

// Libraries
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.system.System;
import nme.ui.Keyboard;
import nme.ui.Mouse;

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
  
  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    addEventListener(Event.ENTER_FRAME, enterFrame);

    var halfHeight = Math.floor(stage.stageHeight / 2);

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
    paletteBox = new PaletteBox(200, halfHeight - 50, 3, 3, setCanvasBrushColor);
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
    brushPopup = new BrushPopup(200, 160, brushFactory, function(picked:Int):Void {
      trace("clicka: " + picked);
      brushFactory.changeBrush(picked);
      cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
    });


    //
    // Setup Toolbox
    //
    toolbox = new Toolbox(200, halfHeight + 50,   3, 4,   8);
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
        canvas.clearCanvas();
      }, 8,                 null, null],
      ['zoomin', function(button):Void {
        canvas.changeZoom(2);
        cursor.changeZoom(Math.floor(canvas.zoom));
      }, 6,                 null, null],
      ['zoomout', function(button):Void {
        canvas.changeZoom(0.5);
        cursor.changeZoom(Math.floor(canvas.zoom));
      }, 7,                 null, null],
      ['palup', function(button) {
        paletteBox.scroll(-1);
      }, 4,                 null, null],
      ['paldown', function(button) {
        paletteBox.scroll(1);
      }, 5,                 null, null]
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


    //
    // Add Events
    //
    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);

    canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
    canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);
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

  private function stageMouseMove(event:MouseEvent):Void {
    cursor.update(event.stageX, event.stageY);
  }

  private function stageMouseUp(event:MouseEvent):Void {
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
    trace(keyCode);
  }
}

