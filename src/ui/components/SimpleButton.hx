package ui.components;

import graphics.Color;

import nme.events.MouseEvent;

enum ButtonState {
  normal;
  clicked;
}

class SimpleButton<T> extends Label<T> {
  public var state(default, setState):ButtonState;
  private var originalBackround:Color;

  public var clickBackground:Color;
  public var onClick:Void->Void;

  public function new(content:T, ?margin:Int = 0) {
    super(content, margin);
    state = normal;

    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }

  private function setState(s:ButtonState):ButtonState {
    if (state != s) {
      if (state == normal && s == clicked) {
        originalBackround = background;
        background = clickBackground;
      } else if (state == clicked && s == normal) {
        background = originalBackround;
      }
      state = s;

      redraw();
    }

    return s;
  }

  //
  // Event Handlers
  //
  public function onMouseUp(event:MouseEvent) {
    if (state == clicked) {
      if (onClick != null) {
        onClick();
      }
      state = normal;
    }
  }

  public function onMouseDown(event:MouseEvent) {
    state = clicked;
  }

  public function onMouseOut(event:MouseEvent) {
    state = normal;
  }

}

