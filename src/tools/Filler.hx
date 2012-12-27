package tools;

import tools.ITool;
import ui.Canvas;

import nme.events.MouseEvent;

class Filler implements ITool {
  public var imageFile:String;
  public var imageIndex:Int;
  public var name:String;

  public function new() {
    name = "filler";
    imageIndex = 3;
    imageFile = "toolbox.png";
  }

  public function isMomentary():Bool {
    return false;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.fill(Math.floor(event.localX / canvas.zoom), Math.floor(event.localY / canvas.zoom));
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
  }
}


