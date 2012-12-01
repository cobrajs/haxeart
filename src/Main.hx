package ;

// UI Elements
import ui.Button;
import ui.Toolbox;
import ui.Canvas;
import ui.PaletteBox;
import ui.Cursor;

// Graphical Helpers
import graphics.BrushFactory;

// Iterators
import util.LineIter;

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
  
  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    addEventListener(Event.ENTER_FRAME, enterFrame);

    var halfHeight = Math.floor(stage.stageHeight / 2);

    brushFactory = new BrushFactory("brushes.png", 7, 7, 0xFF00FF);

    canvas = new Canvas(200, 200, brushFactory);
    canvas.moveTo(
        Math.floor(200 + ((stage.stageWidth - 200) / 2) - canvas.uWidth / 2), 
        Math.floor(stage.stageHeight / 2 - canvas.uHeight / 2)
    );

    addChild(canvas);

    toolbox = new Toolbox(200, halfHeight,   2, 4,   8);
    toolbox.x = 0;
    toolbox.y = 0;

    toolbox.setTilesheet("toolbox.png", 4, 4, 0xFF00FF);
    toolbox.addButton(canvas.redShift, 0);
    toolbox.addButton(drawLine, 0);
    toolbox.addButton(canvas.noise, 1);
    toolbox.addButton(clearCanvas, 2);
    toolbox.addButton(zoomInCanvas, 6);
    toolbox.addButton(zoomOutCanvas, 7);
    toolbox.addButton(brushIncrease, 4);
    toolbox.addButton(brushDecrease, 5);

    addChild(toolbox);

    paletteBox = new PaletteBox(200, halfHeight, 3, 4, setCanvasBrushColor);
    paletteBox.x = 0;
    paletteBox.y = halfHeight;

    // Greyscale
    paletteBox.addColor(0xFFFFFF);
    paletteBox.addColor(0xCCCCCC);
    paletteBox.addColor(0x999999);
    paletteBox.addColor(0x666666);
    paletteBox.addColor(0x333333);
    paletteBox.addColor(0x000000);

    // Colors
    paletteBox.addColor(0xFF0000);
    paletteBox.addColor(0x00FF00);
    paletteBox.addColor(0x0000FF);
    paletteBox.addColor(0xFF00FF);
    paletteBox.addColor(0xFFFF00);
    paletteBox.addColor(0x00FFFF);

    addChild(paletteBox);

    cursor = new Cursor();
    cursor.addTypeCursor("canvas", brushFactory.getBrushImage());
    addChild(cursor);

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

  private function clearCanvas():Void {
    canvas.clearCanvas();
  }

  private function zoomInCanvas():Void {
    canvas.changeZoom(2);
  }

  private function zoomOutCanvas():Void {
    canvas.changeZoom(0.5);
  }

  private function brushIncrease():Void {
    canvas.changeBrushSize(1);
  }

  private function brushDecrease():Void {
    canvas.changeBrushSize(-1);
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
  }
}

