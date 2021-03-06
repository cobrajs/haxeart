package tools;

import ui.Canvas;
import flash.events.MouseEvent;

interface ITool {
  var imageFile:String;
  var imageIndex:Int;
  var name:String;

  function isMomentary():Bool;
  function modifiesCanvas():Bool;
  function mouseDownAction(canvas:Canvas, event:MouseEvent):Void;
  function mouseMoveAction(canvas:Canvas, event:MouseEvent):Void;
  function mouseUpAction(canvas:Canvas, event:MouseEvent):Void;
}
