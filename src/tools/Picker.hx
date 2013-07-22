package tools;

import tools.ITool;
import ui.Canvas;

import flash.events.MouseEvent;

class Picker implements ITool {
  public var imageFile:String;
  public var imageIndex:Int;
  public var pickAction:Int->Void;
  public var name:String;

  public function new(pickAction:Int->Void) {
    name = "picker";
    imageIndex = 2;
    imageFile = "toolbox.png";

    this.pickAction = pickAction;
  }

  public function isMomentary():Bool {
    return true;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    var color:Int = canvas.getPoint(Math.floor(event.localX / canvas.zoom), Math.floor(event.localY / canvas.zoom));
    pickAction(color);
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
  }
}

