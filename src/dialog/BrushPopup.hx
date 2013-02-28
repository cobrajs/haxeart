package dialog;

// TODO: Replace with components

import ui.layouts.BorderLayout;
import dialog.Popup;

import graphics.BrushFactory;

import nme.events.MouseEvent;
import nme.display.BitmapData;
import nme.display.Graphics;

class BrushPopup extends Popup {
  private var brushFactory:BrushFactory;
  private var pickAction:Int->Void;
  private var background:BitmapData;

  private var xGrid:Int;
  private var yGrid:Int;

  public function new(width:Float, height:Float, brushFactory:BrushFactory, pickAction:Int->Void) {
    super(width, height, "Pick Brush", BorderLayout.MIDDLE, true);
    this.brushFactory = brushFactory;

    this.pickAction = pickAction;

    background = new BitmapData(Std.int(uWidth), Std.int(uHeight));

    xGrid = 7;
    yGrid = 4;
    for (y in 0...yGrid) {
      for (x in 0...xGrid) {
        brushFactory.drawBrushScale(
          background, 
          Math.floor(xGrid + x * (uWidth / xGrid) + brushFactory.tileWidth), 
          Math.floor(yGrid + y * (uHeight / yGrid)) + brushFactory.tileHeight, 
          (y * xGrid) + x,
          2
        );
      }
    }

    window.background = null;
    window.predraw = function(gfx:Graphics, width, height) {
      gfx.beginBitmapFill(background);
      gfx.drawRect(0, 0, width, height);
      gfx.endFill();
    };
  }

  override function onMouseUp(event:MouseEvent) {
    if (event.target == window) {
      var tempX = Math.floor(event.localX / (uWidth / xGrid));
      var tempY = Math.floor(event.localY / (uHeight / yGrid));
      pickAction(tempY * xGrid + tempX);
      hide();
    }
    else if (event.target == closeButton) {
      hide();
    }
    else {
    }
  }
}
