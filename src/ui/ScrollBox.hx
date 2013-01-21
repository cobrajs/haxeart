package ui;

import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.events.Event;
import nme.events.MouseEvent;

class ScrollBox extends Sprite {
  private var scrollBoxRect:Rectangle;
  private var originClick:Point;
  private var originPoint:Point;
  private var scrollTolerance:Int;
  private var checkTolerance:Bool;

  public function new(width:Int, height:Int, ?scrollTolerance:Int = 5) {
    super();
    scrollBoxRect = new Rectangle(0, 0, width, height);
    refreshScrollRect();

    this.scrollTolerance = scrollTolerance;
    this.checkTolerance  = true;

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function addedToStage(event:Event) {
    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
  }

  private function refreshScrollRect():Void {
    this.scrollRect = scrollBoxRect;
  }

  private function onMouseDown(event:MouseEvent) {
    originClick = new Point(event.stageX, event.stageY);
    originPoint = new Point(scrollBoxRect.x, scrollBoxRect.y);
  }

  private function onMouseMove(event:MouseEvent) {
    if (originClick != null) {
      var diff = originClick.y - event.stageY;
      if ((checkTolerance && Math.abs(diff) > scrollTolerance) || !checkTolerance) {
        scrollBoxRect.y = originPoint.y + diff;
        if (scrollBoxRect.y < 0) {
          scrollBoxRect.y = 0;
        }
        else if (scrollBoxRect.y + scrollBoxRect.height > height) {
          scrollBoxRect.y = height - scrollBoxRect.height;
        }
        refreshScrollRect();
        checkTolerance = false;
      }
    }
  }

  private function onMouseUp(event:MouseEvent) {
    originClick = null;
    originPoint = null;
    checkTolerance = true;
  }

  private function stageMouseMove(event:MouseEvent) {
    if (originClick != null) {
      var diff = originClick.y - event.stageY;
      if ((checkTolerance && Math.abs(diff) > scrollTolerance) || !checkTolerance) {
        scrollBoxRect.y = originPoint.y + diff;
        if (scrollBoxRect.y < 0) {
          scrollBoxRect.y = 0;
        }
        else if (scrollBoxRect.y + scrollBoxRect.height > height) {
          scrollBoxRect.y = height - scrollBoxRect.height;
        }
        refreshScrollRect();
        checkTolerance = false;
      }
    }
  }

  private function stageMouseUp(event:MouseEvent) {
    originClick = null;
    originPoint = null;
    checkTolerance = true;
  }

}
