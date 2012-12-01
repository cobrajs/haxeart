package ui;

import graphics.BrushFactory;
import graphics.Color;

import util.LineIter;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.geom.ColorTransform;

class Canvas extends Sprite {
  private var data:BitmapData;
  private var display:Bitmap;
  private var zoomDisplayData:BitmapData;
  private var zoomDisplay:Bitmap;

  private var zoomPoint:Point;
  private var lastMousePoint:Point;

  public var zoom:Float;

  public var brushSize:Int;
  public var brushColor:Int;

  public var uWidth:Int;
  public var uHeight:Int;

  private var brushFactory:BrushFactory;

  public function new(width:Int, height:Int, brushFactory:BrushFactory) {
    super();

    this.brushFactory = brushFactory;

    uWidth = width;
    uHeight = height;

    zoom = 1;

    brushSize = 5;
    brushColor = 0x000000;

    data = new BitmapData(width, height);
    display = new Bitmap(data);
    display.smoothing = false;

    addChild(display);

    lastMousePoint = new Point(-1, -1);
    zoomPoint = new Point(this.x + width / 2, this.y + height / 2);

    addEventListener(MouseEvent.MOUSE_DOWN, onClick);
    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }

  public function moveTo(x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    zoomPoint.x = this.x + this.width / 2;
    zoomPoint.y = this.y + this.height / 2;
  }

  //
  // Drawing functions
  //
  public function drawDot(x:Int, y:Int) {
    brushFactory.drawBrush(data, x, y);
  }

  public function drawLine(x1:Int, y1:Int, x2:Int, y2:Int) {
    if (y1 == y2) { drawHLine(x1, x2, y1); }
    else if (x1 == x2) { drawVLine(x1, y1, y2); }
    else {
      var difX = x1 - x2, difY = y1 - y2;
      var max = Math.max(Math.abs(difX), Math.abs(difY));
      var stepX:Float = difX / max, stepY:Float = difY / max;
      for (ix in 0...Math.floor(Math.abs(difX))) {
        for (iy in 0...Math.floor(Math.abs(difY))) {
          drawDot(Math.floor(x1 + ix * stepX), Math.floor(y1 + iy * stepY));
        }
      }
    }
  }

  public function drawHLine(x1:Int, x2:Int, y:Int) {
    for (x in x1...x2) {
      drawDot(x, y);
    }
  }

  public function drawVLine(x:Int, y1:Int, y2:Int) {
    for (y in y1...y2) {
      drawDot(x, y);
    }
  }

  public function changeZoom(multiplier:Float) {
    zoom *= multiplier;
    if (zoom < 1) {
      zoom = 1;
    }
    display.scaleX = zoom;
    display.scaleY = zoom;
    this.x = zoomPoint.x - width / 2;
    this.y = zoomPoint.y - height / 2;
  }

  //
  // Brush modification
  //
  public function changeBrushSize(delta:Int) {
    brushSize += delta;
    if (brushSize <= 0) {
      brushSize = 0;
    }
  }

  public function changeBrushColor(color:Int) {
    brushColor = color;
  }

  //
  // Canvas modification
  //
  public function clearCanvas(?color:Int = 0xFFFFFF) {
    data.fillRect(new Rectangle(0, 0, data.width, data.height), Color.getARGB(color, 0xFF));
  }

  public function redShift() {
    data.colorTransform(
        new Rectangle(0, 0, data.width, data.height), 
        new ColorTransform(1, 1, 1, 1, 50, 0, 0, 0)
    );
  }

  public function noise() {
    data.noise(Math.floor(Math.random() * 1000));
  }

  //
  // Event Handlers
  //
  public function onClick(event:MouseEvent) {
    drawDot(Math.floor(event.localX / zoom), Math.floor(event.localY / zoom));
  }

  public function onMouseMove(event:MouseEvent) {
    if (event.buttonDown) {
      if (lastMousePoint.x >= 0 && lastMousePoint.y >= 0) {
        for (p in (new LineIter(
            Math.floor(event.localX / zoom), Math.floor(event.localY / zoom),
            Math.floor(lastMousePoint.x / zoom), Math.floor(lastMousePoint.y / zoom)
        ))) {
          drawDot(p[0], p[1]);
        }
      }
      else {
        drawDot(Math.floor(event.localX / zoom), Math.floor(event.localY / zoom));
      }
      lastMousePoint.x = event.localX;
      lastMousePoint.y = event.localY;
    }
    else {
      lastMousePoint.x = -1;
      lastMousePoint.y = -1;
    }
  }

  public function onMouseUp(event:MouseEvent) {
    zoomPoint.x = event.localX;
    zoomPoint.y = event.localY;
    lastMousePoint.x = -1;
    lastMousePoint.y = -1;
  }

  private function onMouseOut(event:MouseEvent) {
    lastMousePoint.x = -1;
    lastMousePoint.y = -1;
  }

}
