package tools;

import tools.ITool;
import ui.Canvas;

import nme.events.MouseEvent;

class Move implements ITool {
  public var imageFile:String;
  public var imageIndex:Int;

  public function new() {
    imageIndex = 1;
    imageFile = "toolbox.png";
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.startDrag();
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.stopDrag();
  }
}


