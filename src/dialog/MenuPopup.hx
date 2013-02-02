package dialog;

import Registry;
import dialog.Popup;

import ui.components.Label;
import ui.components.Component;

import ui.layouts.GridLayout;

import nme.events.MouseEvent;

class MenuPopup extends Popup {
  public var layout:GridLayout;

  public function new() {
    uWidth = Std.int(Registry.stageWidth); 
    uHeight = Std.int(Registry.stageHeight * 0.3);
    super(uWidth, uHeight);

    window.removeChild(closeButton);
    closeButton = null;

    layout = new GridLayout(uWidth, uHeight, 0, 1);
  }

  public function addComponent(c:Component) {
    window.addChild(c);
    layout.addComponent(c);
  }

  override public function popup(?x:Int, ?y:Int) {
    x = 0;
    y = Std.int(Registry.stageHeight - uHeight);

    super.popup(x, y);
  }

  override public function onMouseUp(event:MouseEvent) {
    if (event.target == overlay) {
      hide();
    }
  }
}
