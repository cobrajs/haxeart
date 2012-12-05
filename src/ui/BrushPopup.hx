package ui;

import ui.Popup;

import graphics.BrushFactory;

import nme.events.MouseEvent;

class BrushPopup extends Popup {
  private var brushFactory:BrushFactory;
  private var pickAction:Void->Void;

  public function new(width:Int, height:Int, brushFactory:BrushFactory, pickAction:Void->Void) {
    super(width, height);
    this.brushFactory = brushFactory;

    this.pickAction = pickAction;
  }


  override function onMouseUp(event:MouseEvent) {
    pickAction();
    var tempX = Math.floor(event.localX / (uWidth / 5));
    var tempY = Math.floor(event.localY / (uHeight / 5));
    trace(tempY * 5 + tempX);
    this.visible = false;
  }
}
