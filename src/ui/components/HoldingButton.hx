package ui.components;

import util.Utils;

import cobraui.components.SimpleButton;

import flash.events.MouseEvent;
import flash.events.Event;
import flash.geom.Point;

class HoldingButton<T> extends SimpleButton<T> {
  private var holdLength:Float;
  private var lastUpdate:Float;
  private var timeLeft:Float;

  public var held:Bool;

  public var onHold:Void->Void;

  public function new(content:T, holdLength:Float, ?margin:Int = 0) {
    super(content, margin);

    this.holdLength = holdLength;
    this.lastUpdate = Utils.getTime();
    this.timeLeft = 0;

    this.held = false;

    addEventListener(Event.ENTER_FRAME, update);
    addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
    addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    addEventListener(MouseEvent.MOUSE_OUT, mouseUp);
  }

  private function update(e:Event) {
    var time = Utils.getTime();
    if (held) {
      var dt = time - lastUpdate;

      timeLeft -= dt;

      if (timeLeft <= 0) {
        releaseButton();
        if (onHold != null) {
          onHold();
        }
      }
    }
    lastUpdate = time;
  }

  private function mouseDown(event:MouseEvent) {
    held = true;
    timeLeft = holdLength;
  }

  private function mouseUp(event:MouseEvent) {
    softRelease();
  }

  public function releaseButton() {
    var upEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false, width / 2, height / 2);
    dispatchEvent(upEvent);
  }

  public function softRelease() {
    held = false;
    timeLeft = 0;
  }
  
  public function clickButton() {
    dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, width / 2, height / 2));
    dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, width / 2, height / 2));
  }

}
