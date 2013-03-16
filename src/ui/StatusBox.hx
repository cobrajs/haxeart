package ui;

import cobraui.components.SimpleButton;
import cobraui.graphics.Color;

import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.geom.Rectangle;

class StatusBox extends SimpleButton<BitmapData> {
  public var imageData:BitmapData;
  public var lastGenSize:String;

  public function new() {
    super(null);
  }

  override public function redraw() {
    if (ready) {
      if ((uWidth + ":" + uHeight) != lastGenSize) {
        var inset = Std.int(uWidth * 0.1);
        if (uWidth - inset > 0 && uHeight - inset > 0) {
          imageData = new BitmapData(Std.int(uWidth - inset), Std.int(uHeight - inset), true);
          var offset = Std.int(imageData.width * 0.2);
          var border = 2;
          var mainColor = Color.getARGB(Registry.canvas.getMainColor(), 255);
          var alternateColor = Color.getARGB(Registry.canvas.getAlternateColor(), 255);

          // Fill back with transparency
          imageData.fillRect(new Rectangle(0, 0, imageData.width, imageData.height), Color.transparent);

          // Draw alternate color
          imageData.fillRect(new Rectangle(offset, offset, imageData.width - offset, imageData.height - offset), mainColor);
          imageData.fillRect(new Rectangle(offset + border, offset + border, imageData.width - offset - border * 2, imageData.height - offset - border * 2), alternateColor);

          // Draw main color
          imageData.fillRect(new Rectangle(0, 0, imageData.width - offset, imageData.height - offset), alternateColor);
          imageData.fillRect(new Rectangle(border, border, imageData.width - offset - border * 2, imageData.height - offset - border * 2), mainColor);

          lastGenSize = (uWidth + ":" + uHeight);
          content = imageData;
        }
      } else {
        super.redraw();
      }
    }
  }

  public function forceRedraw() {
    lastGenSize = "";
    redraw();
  }
}
