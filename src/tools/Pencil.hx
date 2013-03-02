package tools;

import tools.ITool;
import ui.Canvas;
import util.LineIter;

import nme.events.MouseEvent;
import nme.geom.Point;

class Pencil implements ITool {
  private var lastMousePoint:Point;
  private var firstDownPoint:Point;
  public var imageFile:String;
  public var imageIndex:Int;
  public var name:String;
  public var canvasModifySet:Bool;

  private var moved:Bool;
  private var switchColors:Bool;

  public function new() {
    name = "pencil";
    imageIndex = 0;
    imageFile = "toolbox.png";

    moved = false;
    switchColors = false;

    lastMousePoint = new Point(-1, -1);
    firstDownPoint = new Point(-1, -1);
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
    var x = Math.floor(event.localX / canvas.zoom);
    var y = Math.floor(event.localY / canvas.zoom);

    firstDownPoint.x = event.localX;
    firstDownPoint.y = event.localY;

    switchColors = canvas.checkPoint(x, y);
    moved = false;

    canvas.drawDot(x, y);
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
      if (!moved) {
        if (Point.distance(lastMousePoint, firstDownPoint) > canvas.zoom / 2) {
          moved = true;
        }
      }
    }
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    lastMousePoint.x = -1;
    lastMousePoint.y = -1;
    canvasModifySet = false;
    if (!moved && switchColors) {
      var x = Math.floor(event.localX / canvas.zoom);
      var y = Math.floor(event.localY / canvas.zoom);
      canvas.drawDot(x, y, true);
      switchColors = false;
      moved = false;
    }
  }
}

