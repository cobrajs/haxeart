package dialog;

import Registry;
import dialog.Popup;
import dialog.DialogEvent;

import ui.components.Label;
import ui.components.Component;

import ui.layouts.GridLayout;
import ui.layouts.BorderLayout;

import nme.events.MouseEvent;

class MenuPopup extends Popup {
  public static var TYPE:String = "menupopup";
  public var layout:GridLayout;

  public function new() {
    super(1, 0.3, "", BorderLayout.BOTTOM, false);

    layout = new GridLayout(uWidth, uHeight, 0, 1);
  }

  public function addComponent(c:Component) {
    window.addChild(c);
    layout.addComponent(c);
  }

  override public function popup() {
    super.popup();
  }

  override public function onMouseUp(event:MouseEvent) {
    if (event.target == overlay) {
      hide();
    }
  }

  override public function hide() {
    super.hide();
    dispatchEvent(new DialogEvent(DialogEvent.CLOSED, TYPE, this.id, true));
  }
}
