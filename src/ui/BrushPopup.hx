package ui;

import ui.Popup;

import graphics.BrushFactory;

import nme.events.MouseEvent;
import nme.display.BitmapData;

class BrushPopup extends Popup {
  private var brushFactory:BrushFactory;
  private var pickAction:Int->Void;
  private var background:BitmapData;

  private var xGrid:Int;
  private var yGrid:Int;

  public function new(width:Int, height:Int, brushFactory:BrushFactory, pickAction:Int->Void) {
    super(width, height);
    this.brushFactory = brushFactory;

    this.pickAction = pickAction;

    background = new BitmapData(width, height);

    xGrid = 7;
    yGrid = 4;
    for (y in 0...yGrid) {
      for (x in 0...xGrid) {
        brushFactory.drawBrush(
          background, 
          Math.floor(xGrid + x * (width / xGrid)), 
          Math.floor(yGrid + y * (height / yGrid)), 
          (y * xGrid) + x
        );
      }
    }

    var gfx = this.graphics;
    gfx.beginBitmapFill(background);
    gfx.drawRect(0, 0, width, height);
    gfx.endFill();
  }


  override function onMouseUp(event:MouseEvent) {
    var tempX = Math.floor(event.localX / (uWidth / xGrid));
    var tempY = Math.floor(event.localY / (uHeight / yGrid));
    pickAction(tempY * xGrid + tempX);
    hide();
  }
}
