package ui;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.geom.Point;

class Canvas extends Sprite {
  private var data:BitmapData;
  private var display:Bitmap;
  private var zoomDisplayData:BitmapData;
  private var zoomDisplay:Bitmap;

  private var lastPoint:Point;

  public var zoom:Float;

  public var brushSize:Int;
  public var brushColor:Int;

  public var uWidth:Int;
  public var uHeight:Int;

  public function new(width:Int, height:Int) {
    super();

    uWidth = width;
    uHeight = height;

    zoom = 1;

    brushSize = 5;
    brushColor = 0x000000;

    data = new BitmapData(width, height);
    display = new Bitmap(data);
    display.smoothing = false;

    lastPoint = new Point(width / 2, height / 2);

    addChild(display);

    addEventListener(MouseEvent.MOUSE_DOWN, onClick);
    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
  }

  public function onClick(event:MouseEvent) {
    drawDot(Math.floor(event.localX / zoom), Math.floor(event.localY / zoom));
  }

  public function onMouseMove(event:MouseEvent) {
    if (event.buttonDown) {
      drawDot(Math.floor(event.localX / zoom), Math.floor(event.localY / zoom));
    }
  }

  public function onMouseUp(event:MouseEvent) {
    lastPoint.x = event.localX;
    lastPoint.y = event.localY;
  }

  public function updateDisplay() {
  }

  public function drawDot(x:Int, y:Int) {
    data.lock();
    if (brushSize > 0) {
      for (yAdd in -brushSize...brushSize) {
        for (xAdd in -brushSize...brushSize) {
          data.setPixel(x + xAdd, y + yAdd, brushColor);
        }
      }
    }
    else {
      data.setPixel(x, y, brushColor);
    }
    data.unlock();
  }

  public function changeZoom(multiplier:Float) {
    zoom *= multiplier;
    if (zoom < 1) {
      zoom = 1;
    }
    display.scaleX = zoom;
    display.scaleY = zoom;
    //this.x -= (lastPoint.x * zoom) / 2;
    //this.y -= (lastPoint.y * zoom) / 2;
  }

  public function changeBrushSize(delta:Int) {
    brushSize += delta;
    if (brushSize <= 0) {
      brushSize = 0;
    }
  }

  public function changeBrushColor(color:Int) {
    brushColor = color;
  }

  public function clearCanvas(?color:Int = 0xFFFFFFFF) {
#if neko
    data.fillRect(new Rectangle(0, 0, data.width, data.height), {rgb: color, a: 0xFF});
#else
    data.fillRect(new Rectangle(0, 0, data.width, data.height), color);
#end
  }
}
