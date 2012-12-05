package tools;

import tools.ITool;
import ui.Canvas;

import nme.events.MouseEvent;

class Filler implements ITool {
  public var imageFile:String;
  public var imageIndex:Int;

  public function new() {
    imageIndex = 3;
    imageFile = "toolbox.png";
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.fill(Math.floor(event.localX / canvas.zoom), Math.floor(event.localY / canvas.zoom));
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
  }
}


