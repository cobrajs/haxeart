package tools;

import tools.ITool;
import ui.Canvas;

import nme.events.MouseEvent;

class Move implements ITool {
  public var imageFile:String;
  public var imageIndex:Int;
  public var revert:Bool;
  public var revertAction:Void->Void;
  public var name:String;

  public function new(revertAction:Void->Void) {
    name = "move";
    imageIndex = 1;
    imageFile = "toolbox.png";
    revert = false;
    this.revertAction = revertAction;
  }

  public function isMomentary():Bool {
    return revert;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.startDrag();
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.stopDrag();
    if (revert) {
      revertAction();
      revert = false;
    }
  }
}


