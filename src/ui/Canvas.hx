package ui;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.geom.Rectangle;

class Canvas extends Sprite {
  private var data:BitmapData;
  private var display:Bitmap;
  private var zoomDisplayData:BitmapData;
  private var zoomDisplay:Bitmap;

  private var uWidth:Int;
  private var uHeight:Int;

  public function new(width:Int, height:Int) {
    super();

    uWidth = width;
    uHeight = height;

    data = new BitmapData(width, height);
    display = new Bitmap(data);

    addChild(display);

    addEventListener(MouseEvent.MOUSE_DOWN, onClick);
    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
  }

  public function onClick(event:MouseEvent) {
    drawDot(Math.floor(event.localX), Math.floor(event.localY));
  }

  public function onMouseMove(event:MouseEvent) {
    if (event.buttonDown) {
      drawDot(Math.floor(event.localX), Math.floor(event.localY));
    }
  }

  public function updateDisplay() {
  }

  public function drawDot(x:Int, y:Int) {
    data.lock();
    for (yAdd in -5...5) {
      for (xAdd in -5...5) {
        data.setPixel(x + xAdd, y + yAdd, 0x000000);
      }
    }
    data.unlock();
  }

  public function clearCanvas(?color:Int = 0xFFFFFFFF) {
#if neko
    data.fillRect(new Rectangle(0, 0, data.width, data.height), {rgb: color, a: 0xFF});
#else
    data.fillRect(new Rectangle(0, 0, data.width, data.height), color);
#end
  }
}
