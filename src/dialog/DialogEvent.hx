package dialog;

import nme.events.Event;

class DialogEvent extends Event {
  public static var MESSAGE:String = "DialogMessageEvent";
  public static var CLOSED:String = "DialogClosedEvent";
  public var message:String;
  public var id:Int;
  public function new(label:String, message:String, id:Int, ?bubbles:Bool = true, ?cancelable:Bool = false) {
    super(label, bubbles, cancelable);
    this.message = message;
    this.id = id;
  }
}
