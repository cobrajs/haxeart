package ui.components;

import ui.components.Label;
import graphics.Color;

import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;

class TextInput extends Label<String> {
  public var active:Bool;

  public function new(?defaultText:String) {
    super(defaultText == null ? "" : defaultText);

    background = new Color("white");
    borderWidth = 2;

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function addedToStage(event:Event) {
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function onKeyDown(event:KeyboardEvent) {
    if (this.active) {
      var char = String.fromCharCode(event.charCode);
      if (event.charCode >= 32) {
        content += String.fromCharCode(event.charCode);
      } else {
        switch(event.keyCode) {
          case Keyboard.BACKSPACE:
            content = content.substr(0, content.length - 1);
        }
      }
      trace(event.keyCode);
    }
  }

}
