package tools;

import ui.Canvas;
import nme.events.MouseEvent;

interface ITool {
  var imageFile:String;
  var imageIndex:Int;

  function mouseDownAction(canvas:Canvas, event:MouseEvent):Void;
  function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void;
  function mouseUpAction(canvas:Canvas, event:MouseEvent):Void;
}
