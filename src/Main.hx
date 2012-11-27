package ;

// UI Elements
import ui.Button;
import ui.Toolbox;
import ui.Canvas;

// Libraries
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.system.System;
import nme.ui.Keyboard;

class Main extends Sprite {

  private var buttons:Array<Button>;
  private var toolbox:Toolbox;

  private var canvas:Canvas;
  
  public function new() {
    super();

    //trace("TEST");
    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    addEventListener(Event.ENTER_FRAME, enterFrame);

    toolbox = new Toolbox(200, stage.stageHeight,   2, 4,   4);
    toolbox.x = 0;
    toolbox.y = 0;

    toolbox.setTilesheet("toolbox.png", 4, 4, 0xFF00FF);
    toolbox.addButton(drawRedCircle, 0);
    toolbox.addButton(drawBlueCircle, 0);
    toolbox.addButton(drawGreenCircle, 1);
    toolbox.addButton(clearCanvas, 2);

    addChild(toolbox);

    canvas = new Canvas(stage.stageWidth - 200, stage.stageHeight);
    canvas.x = 200;

    addChild(canvas);
    
    /*
    buttons = new Array<Button>();

    var tempHeight = 64;
    var button = new Button(128, tempHeight);
    button.x = 0;
    button.y = stage.stageHeight - tempHeight;
    button.clickAction = drawRedCircle;
    button.setText("Red Circle");
    addChild(button);
    buttons.push(button);

    var button = new Button(128, tempHeight, 0);
    button.x = 128;
    button.y = stage.stageHeight - tempHeight;
    button.clickAction = drawGreenCircle;
    button.setText("Green Circle");
    addChild(button);
    buttons.push(button);

    var button = new Button(128, tempHeight, 12);
    button.x = 256;
    button.y = stage.stageHeight - tempHeight;
    button.clickAction = drawBlueCircle;
    button.setText("Blue Circle");
    addChild(button);
    buttons.push(button);

    var button = new Button(128, tempHeight, 12);
    button.x = 384;
    button.y = stage.stageHeight - tempHeight;
    button.clickAction = drawBlueCircle;
    button.setImage("percent.png");
    addChild(button);
    buttons.push(button);

    var button = new Button(128, tempHeight, 12);
    button.x = 512;
    button.y = stage.stageHeight - tempHeight;
    button.clickAction = clearCanvas;
    button.setText("Clear");
    addChild(button);
    buttons.push(button);
    */

    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
  }
  
  private function update():Void {

  }

  private function drawRedCircle():Void { drawCircle(0xFF0000); }
  private function drawGreenCircle():Void { drawCircle(0x00FF00); }
  private function drawBlueCircle():Void { drawCircle(0x0000FF); }
  private function drawCircle(color:Int):Void {
    var gfx = this.graphics;
    var tempX = Math.random() * stage.stageWidth;
    var tempY = Math.random() * (stage.stageHeight - 64);
    //trace(tempX + "  " + tempY);
    gfx.beginFill(color);
    gfx.drawCircle(tempX, tempY, 30);
    gfx.endFill();
  }

  private function clearCanvas():Void {
    this.graphics.clear();
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
    //trace(keyCode);
    if (keyCode == Keyboard.ESCAPE) {
      System.exit(0);
    }
    else if (keyCode == Keyboard.V) {
      drawBlueCircle();
    }
  }
}

