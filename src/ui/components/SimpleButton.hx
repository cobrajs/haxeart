package ui.components;

import graphics.Color;

import nme.events.MouseEvent;

enum ButtonState {
  normal;
  clicked;
}

class SimpleButton<T> extends Label<T> {
  public var state(default, setState):ButtonState;
  public var stickyState:Bool;
  private var originalBackround:Color;

  public var clickBackground:Color;
  public var onClick:MouseEvent->Void;

  public function new(content:T, ?margin:Int = 0) {
    super(content, margin);

    // Default is the centered
    this.hAlign = center;
    this.vAlign = middle;

    state = normal;
    stickyState = false;

    clickBackground = new Color(0x777777);

    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }

  private function setState(newState:ButtonState):ButtonState {
    if (state != newState) {
      if (state == normal && newState == clicked) {
        originalBackround = background;
        background = clickBackground;
      } else if (state == clicked && newState == normal) {
        background = originalBackround;
      }
      state = newState;

      redraw();
    }

    return newState;
  }

  //
  // Event Handlers
  //
  public function onMouseUp(event:MouseEvent) {
    if (state == clicked) {
      if (onClick != null) {
        onClick(event);
      }
      if (!stickyState) {
        state = normal;
      }
    }
  }

  public function onMouseDown(event:MouseEvent) {
    state = clicked;
  }

  public function onMouseOut(event:MouseEvent) {
    if (!stickyState) {
      state = normal;
    }
  }

}

