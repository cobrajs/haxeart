package dialog;

import ui.components.SimpleButton;
import ui.layouts.BorderLayout;
import ui.layouts.GridLayout;
import dialog.Popup;

import graphics.BrushFactory;
import graphics.Color;

import nme.events.MouseEvent;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Rectangle;

class BrushPopup extends Popup {
  private var brushFactory:BrushFactory;
  private var pickAction:Int->Void;
  private var background:BitmapData;

  private var xGrid:Int;
  private var yGrid:Int;

  private var buttons:Array<SimpleButton<BitmapData>>;

  public function new(width:Float, height:Float, brushFactory:BrushFactory, pickAction:Int->Void) {
    super(width, height, "Pick Brush", BorderLayout.MIDDLE, true);
    this.brushFactory = brushFactory;

    this.pickAction = pickAction;

    buttons = new Array<SimpleButton<BitmapData>>();
    layout = new GridLayout(uWidth, uHeight, brushFactory.tilesX, brushFactory.tilesY);

    var brushScale = 4;

    xGrid = brushFactory.tilesX;
    yGrid = brushFactory.tilesY;
    for (y in 0...yGrid) {
      for (x in 0...xGrid) {
        var temp = new BitmapData(brushFactory.tileWidth * brushScale, brushFactory.tileHeight * brushScale, true);
        temp.fillRect(new Rectangle(0, 0, temp.width, temp.height), Color.transparent);
        var index = (y * xGrid) + x;
        brushFactory.drawBrushScale(
          temp, 
          Std.int(brushFactory.tileWidth * brushScale / 2),
          Std.int(brushFactory.tileHeight * brushScale / 2),
          index,
          brushScale
        );
        var tempButton = new SimpleButton<BitmapData>(temp);
        tempButton.borderWidth = 0;
        tempButton.onClick = function(event:MouseEvent) {
          pickAction(index);
          hide();
        };
        window.addChild(tempButton);
        layout.addComponent(tempButton);
        buttons.push(tempButton);
      }
    }

    layout.pack();
  }

  override private function sizeToStage() {
    super.sizeToStage();

    layout.resize(uWidth, uHeight);
  }

  override function onMouseUp(event:MouseEvent) {
    if (event.target == overlay) {
      hide();
    }
  }
}
