package ;

import nme.events.Event;

class ClickEvent extends Event {
  public static var HOLD_CLICK:String = "HoldClick";
  public var stageX:Float;
  public var stageY:Float;
  public var localX:Float;
  public var localY:Float;
  public function new(label:String, stageX:Float, stageY:Float, localX:Float, localY:Float, ?bubbles:Bool = true, ?cancelable:Bool = false) {
    super(label, bubbles, cancelable);
    this.stageX = stageX;
    this.stageY = stageY;
    this.localX = localX;
    this.localY = localY;
  }
}

