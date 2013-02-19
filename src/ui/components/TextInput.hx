package ui.components;

import ui.components.Label;
import graphics.Color;

import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;

class TextInput extends Label<String> {
  public var active:Bool;
  public var allowed:EReg;
  public var cursor:Int;

  public function new(?defaultText:String) {
    super(defaultText == null ? "" : defaultText);

    background = new Color("white");
    borderWidth = 2;

    needsSoftKeyboard = true;

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  public function activate() {
    active = true;
    requestSoftKeyboard();
  }

  public function deactivate() {
    active = false;
  }

  private function addedToStage(event:Event) {
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function onKeyDown(event:KeyboardEvent) {
    if (this.active) {
      var char = String.fromCharCode(event.charCode);
      if (event.charCode >= 32) {
        if (allowed == null || (allowed != null && allowed.match(char))) {
          content += char;
        }
      } else {
        switch(event.keyCode) {
          case Keyboard.BACKSPACE:
            content = content.substr(0, content.length - 1);
        }
      }
    }
  }

}
