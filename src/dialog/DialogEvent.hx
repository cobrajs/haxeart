package dialog;

import nme.events.Event;

class DialogEvent extends Event {
  public static var MESSAGE:String = "DialogMessageEvent";
  public static var CLOSED:String = "DialogClosedEvent";
  public var message:String;
  public function new(label:String, message:String, ?bubbles:Bool = true, ?cancelable:Bool = false) {
    super(label, bubbles, cancelable);
    this.message = message;
  }
}
