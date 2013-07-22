package ui;

import flash.events.Event;

class CustomEvents extends Event {
  public static var RESIZE_PALETTE:String = "ResizePaletteEvent";
  public var message:String;
  public function new(label:String, message:String, ?bubbles:Bool = true, ?cancelable:Bool = false) {
    super(label, bubbles, cancelable);
    this.message = message;
  }
}
