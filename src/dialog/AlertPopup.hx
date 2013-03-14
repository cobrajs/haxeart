package dialog;

import dialog.Popup;
import dialog.DialogEvent;

import ui.components.Label;
import ui.components.SimpleButton;
import ui.components.Container;

import ui.layouts.GridLayout;
import ui.layouts.BorderLayout;

import nme.events.MouseEvent;

enum PopupType {
  alert;
  confirm;
}

class AlertPopup extends Popup {
  public static var TYPE:String = "alertpopup";

  private var message:String;
  private var type:PopupType;

  private var label:Label<String>;
  private var buttons:Container;

  public function new(message:String, type:PopupType, ?titleLabel:String) {
    super(0.7, 0.4, titleLabel != null ? titleLabel : "Alert", BorderLayout.MIDDLE, false);

    layout = new BorderLayout(uWidth, uHeight);

    buttons = new Container();
    buttons.layout = new GridLayout(10, 10, 0, 1);
    this.type = type;
    var tempButton:SimpleButton<String> = null;
    var messageAndClose = function(message:String) {
      dispatchEvent(new DialogEvent(DialogEvent.MESSAGE, message, this.id));
      dispatchEvent(new DialogEvent(DialogEvent.CLOSED, TYPE, this.id));
      this.hide();
    };
    if (type == alert) {
      tempButton = new SimpleButton<String>("OK");
      tempButton.onClick = function(event:MouseEvent) {
        messageAndClose("");
      }
      buttons.addChild(tempButton);
      buttons.layout.addComponent(tempButton);
    } else if (type == confirm) {
      tempButton = new SimpleButton<String>("Yes");
      tempButton.onClick = function(event:MouseEvent) {
        messageAndClose("yes");
      }
      buttons.addChild(tempButton);
      buttons.layout.addComponent(tempButton);
      tempButton = new SimpleButton<String>("No");
      tempButton.onClick = function(event:MouseEvent) {
        messageAndClose("no");
      }
      buttons.addChild(tempButton);
      buttons.layout.addComponent(tempButton);
    }
    window.addChild(buttons);
    buttons.layout.pack();

    layout.assignComponent(buttons, BorderLayout.BOTTOM_RIGHT, 0.7, 0.3, percent);
    label = new Label<String>(message);
    label.hAlign = center;
    label.background = null;
    window.addChild(label);
    layout.assignComponent(label, BorderLayout.TOP_RIGHT, 1, 0.7, percent);
    layout.pack();
  }

}
