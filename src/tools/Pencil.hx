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
  public var canvasModifySet:Bool;

  public function new() {
    name = "pencil";
    imageIndex = 0;
    imageFile = "toolbox.png";

    lastMousePoint = new Point(-1, -1);
    canvasModifySet = false;
  }

  public function isMomentary():Bool {
    return false;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    if (!canvasModifySet) {
      canvas.canvasModified();
      canvasModifySet = true;
    }
    canvas.drawDot(
      Math.floor(event.localX / canvas.zoom), 
      Math.floor(event.localY / canvas.zoom)
    );
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
    if (event.buttonDown) {
      if (lastMousePoint.x >= 0 && lastMousePoint.y >= 0) {
        for (p in (new LineIter(
            Math.floor(event.localX / canvas.zoom), Math.floor(event.localY / canvas.zoom),
            Math.floor(lastMousePoint.x / canvas.zoom), Math.floor(lastMousePoint.y / canvas.zoom)
        ))) {
          canvas.drawDot(p[0], p[1]);
        }
      }
      else {
        canvas.drawDot(Math.floor(event.localX / canvas.zoom), Math.floor(event.localY / canvas.zoom));
        if (!canvasModifySet) {
          canvas.canvasModified();
          canvasModifySet = true;
        }
      }
      lastMousePoint.x = event.localX;
      lastMousePoint.y = event.localY;
    }
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    lastMousePoint.x = -1;
    lastMousePoint.y = -1;
    canvasModifySet = false;
  }
}

