package ;

import nme.events.TouchEvent;
import nme.ui.Multitouch;
import nme.geom.Point;

class TouchManager {
  // Touch Gesture stuff
  public var threshold:Int;
  public var originPoint:Point;

  public var originPoints:IntHash<Point>;
  public var touchPoints:IntHash<Point>;
  public var touchCount:Int;

  public var newScale:Float;

  public function new() {
    originPoints = new IntHash<Point>();
    touchPoints = new IntHash<Point>();
    touchCount = 0;
  }

  public function onTouchBegin(event:TouchEvent) {
    if (event.target != event.currentTarget) {
      return;
    }

    if (touchCount < 2) {
      originPoints.set(event.touchPointID, new Point(event.stageX, event.stageY));
      touchPoints.set(event.touchPointID, new Point(event.stageX, event.stageY));
      touchCount++;
    }
  }

  public function onTouchMove(event:TouchEvent) {
    if (event.target != event.currentTarget) {
      return;
    }

    if (touchPoints.exists(event.touchPointID)) {
      var point = touchPoints.get(event.touchPointID);
      point.x = event.stageX;
      point.y = event.stageY;

      if (touchCount == 2) {
        var dif:Float = 0;
        var firstKey = -1;
        var secondKey = -1;
        for (key in touchPoints.keys()) {
          if (firstKey == -1) {
            firstKey = key;
            continue;
          } else if (secondKey == -1) {
            secondKey = key;
            break;
          }
        }
        var originDist = Point.distance(originPoints.get(firstKey), originPoints.get(secondKey));
        var newDist    = Point.distance(touchPoints.get(firstKey), touchPoints.get(secondKey));
        newScale = 1 + (newDist - originDist) / 100;
      }

      var point = originPoints.get(event.touchPointID);
      point.x = event.stageX;
      point.y = event.stageY;
    }
  }

  private function onTouchEnd(event:TouchEvent):Void {
    if (event.target != event.currentTarget) {
      return;
    }

    if (touchPoints.exists(event.touchPointID)) {
      touchPoints.remove(event.touchPointID);
      originPoints.remove(event.touchPointID);
      touchCount--;
    }
  }

}
