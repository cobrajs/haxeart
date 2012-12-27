package tools;

import tools.ITool;
import ui.Canvas;
import util.LineIter;

import nme.events.MouseEvent;
import nme.geom.Point;

class Pencil implements ITool {
  private var lastMousePoint:Point;
  public var imageFile:String;
  public var imageIndex:Int;
  public var name:String;

  public function new() {
    name = "pencil";
    imageIndex = 0;
    imageFile = "toolbox.png";

    lastMousePoint = new Point(-1, -1);
  }

  public function isMomentary():Bool {
    return false;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    canvas.drawDot(Math.ceil(event.localX / canvas.zoom), Math.ceil(event.localY / canvas.zoom));
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
    if (event.buttonDown) {
      if (lastMousePoint.x >= 0 && lastMousePoint.y >= 0) {
        for (p in (new LineIter(
            Math.ceil(event.localX / canvas.zoom), Math.ceil(event.localY / canvas.zoom),
            Math.ceil(lastMousePoint.x / canvas.zoom), Math.ceil(lastMousePoint.y / canvas.zoom)
        ))) {
          canvas.drawDot(p[0], p[1]);
        }
      }
      else {
        canvas.drawDot(Math.ceil(event.localX / canvas.zoom), Math.ceil(event.localY / canvas.zoom));
      }
      lastMousePoint.x = event.localX;
      lastMousePoint.y = event.localY;
    }
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    lastMousePoint.x = -1;
    lastMousePoint.y = -1;
  }
}

