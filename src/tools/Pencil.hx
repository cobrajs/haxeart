package tools;

import tools.ITool;
import ui.Canvas;
import util.LineIter;
import util.Utils;

import flash.events.MouseEvent;
import flash.geom.Point;

class Pencil implements ITool {
  // Double click movement
  private static var doubleClickTime:Float = 0.5;
  private static var CANVAS_MOVE:Int = 1;
  private static var CANVAS_ZOOM:Int = 2;
  private var lastMousePointDouble:Point;
  private var doubleTime:Float;
  private var canvasMoveMode:Bool;
  private var canvasMoveType:Int;
  private var doubleClickMovement:Point;
  private var doubleClickLastPoint:Point;

  private var lastMousePoint:Point;
  private var firstDownPoint:Point;
  public var imageFile:String;
  public var imageIndex:Int;
  public var name:String;
  public var canvasModifySet:Bool;

  private var initiatedDraw:Bool;

  private var moved:Bool;
  private var switchColors:Bool;

  public function new() {
    name = "pencil";
    imageIndex = 0;
    imageFile = "toolbox.png";

    initiatedDraw = false;

    moved = false;
    switchColors = false;

    lastMousePointDouble = new Point(-1, -1);
    doubleClickMovement = new Point(0, 0);
    doubleClickLastPoint = new Point(0, 0);
    doubleTime = 0;
    canvasMoveMode = false;
    canvasMoveType = 0;

    lastMousePoint = new Point(-1, -1);
    firstDownPoint = new Point(-1, -1);
    canvasModifySet = false;
  }

  public function isMomentary():Bool {
    return false;
  }

  public function mouseDownAction(canvas:Canvas, event:MouseEvent):Void {
    if (Utils.getTime() - doubleTime < doubleClickTime) {
      switchColors = false;
      lastMousePointDouble.x = -1;
      lastMousePointDouble.y = -1;
      canvas.undoStep();
      canvasMoveMode = true;
      canvasMoveType = 0;
      doubleClickMovement.x = 0;
      doubleClickMovement.y = 0;
      doubleClickLastPoint.x = event.localX;
      doubleClickLastPoint.y = event.localY;
      return;
    } else {
      lastMousePointDouble.x = event.localX;
      lastMousePointDouble.y = event.localY;
      doubleTime = Utils.getTime();
    }

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

    initiatedDraw = true;
  }

  public function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void {
    if (canvasMoveMode) {
      if (canvasMoveType == 0 || canvasMoveType == CANVAS_ZOOM) {
        //doubleClickMovement.x += doubleClickLastPoint.x - event.localX;
        //doubleClickMovement.y += doubleClickLastPoint.y - event.localY;
        //doubleClickLastPoint.x = event.localX;
        //doubleClickLastPoint.y = event.localY;
      }
      if (canvasMoveType == 0) {
        if (Math.abs(doubleClickLastPoint.x - event.localX) > 10 || Math.abs(doubleClickLastPoint.y - event.localY) > 10) {
          if (Math.abs(doubleClickLastPoint.x - event.localX) > 10) {
            canvas.startDrag();
            canvasMoveType = CANVAS_MOVE;
          } else {
            canvasMoveType = CANVAS_ZOOM;
            doubleClickMovement.x = 0;
            doubleClickMovement.y = 0;
            doubleClickLastPoint.y = event.stageY;
          }
        }
      } else {
        if (canvasMoveType == CANVAS_ZOOM) {
          var diff = doubleClickLastPoint.y - event.stageY;
          var zoom = 1 + (diff / 10 * (1 / canvas.zoom)); 
          //var zoom = 1 + (diff / 10 * Math.exp(-Math.sqrt(canvas.zoom)));
          if (Math.abs(zoom) < 2 && zoom > 0) {
            canvas.changeZoom(zoom);
            Registry.cursor.changeZoom(canvas.zoom);
          }
          doubleClickLastPoint.y = event.stageY;
        }
      }
      return;
    }
    if (event.buttonDown && initiatedDraw) {
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
          canvas.drawDot(Math.floor(firstDownPoint.x / canvas.zoom), Math.floor(firstDownPoint.y  / canvas.zoom));
        }
      }
    }
  }

  public function mouseUpAction(canvas:Canvas, event:MouseEvent):Void {
    if (canvasMoveMode) {
      if (canvasMoveType == CANVAS_MOVE) {
        canvas.stopDrag();
      } else {
      }

      canvasMoveType = 0;
      canvasMoveMode = false;
    }

    if (initiatedDraw) {
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

      initiatedDraw = false;
    }
  }
}

