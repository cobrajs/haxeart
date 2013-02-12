package dialog;

import dialog.Popup;
import dialog.DialogEvent;

import ui.components.Label;
import ui.components.Container;
import ui.components.SimpleButton;
import ui.components.TextInput;

import ui.layouts.GridLayout;
import ui.layouts.BorderLayout;

import nme.events.MouseEvent;

class PromptPopup extends Popup {
  public static var TYPE:String = "promptpopup";

  private var value:String;
  private var message:String;

  private var layout:BorderLayout;

  private var textBox:TextInput;
  private var buttons:Container;

  public function new(defaultText:String, ?titleLabel:String) {
    super(0.7, 0.4, titleLabel != null ? titleLabel : "Prompt", BorderLayout.MIDDLE, false);

    layout = new BorderLayout(uWidth, uHeight);

    buttons = new Container();
    buttons.layout = new GridLayout(10, 10, 0, 1);
    var tempButton:SimpleButton<String> = null;
    var messageAndClose = function(message:String) {
      dispatchEvent(new DialogEvent(DialogEvent.MESSAGE, message, id));
      dispatchEvent(new DialogEvent(DialogEvent.CLOSED, TYPE, id));
      this.hide();
    };
    tempButton = new SimpleButton<String>("OK");
    tempButton.borderWidth = 1;
    tempButton.onClick = function(event:MouseEvent) {
      messageAndClose(textBox.content);
    }
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    /*
    } else if (type == confirm) {
      tempButton = new SimpleButton<String>("Yes");
      tempButton.borderWidth = 1;
      tempButton.onClick = function(event:MouseEvent) {
        messageAndClose("yes");
      }
      buttons.addChild(tempButton);
      buttons.layout.addComponent(tempButton);
      tempButton = new SimpleButton<String>("No");
      tempButton.borderWidth = 1;
      tempButton.onClick = function(event:MouseEvent) {
        messageAndClose("no");
      }
      buttons.addChild(tempButton);
      buttons.layout.addComponent(tempButton);
    }
    */
    window.addChild(buttons);
    buttons.layout.pack();

    layout.assignComponent(buttons, BorderLayout.BOTTOM_RIGHT, 0.7, 0.3, percent);
    textBox = new TextInput(defaultText);
    textBox.hAlign = center;
    window.addChild(textBox);
    layout.assignComponent(textBox, BorderLayout.TOP_RIGHT, 1, 0.7, percent);
    layout.pack();
  }

  override public function popup() {
    super.popup();
    textBox.active = true;
  }

  override public function hide() {
    super.hide();
    textBox.active = false;
  }

}

