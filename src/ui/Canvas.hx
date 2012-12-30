package ui;

import com.eclecticdesignstudio.motion.Actuate;

import graphics.BrushFactory;
import graphics.Color;

import util.LineIter;

import tools.ITool;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.display.LineScaleMode;


import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.geom.ColorTransform;

class Canvas extends Sprite {
  private var undoSteps:Array<BitmapData>;
  private var redoSteps:Array<BitmapData>;
  private var maxUndoSteps:Int;
  private var data:BitmapData;
  private var display:Bitmap;
  private var grid:Shape;
  private var zoomDisplayData:BitmapData;
  private var zoomDisplay:Bitmap;
  public var originalPos:Point;

  private var zoomPoint:Point;
  private var lastMousePoint:Point;

  public var zoom:Float;

  public var brushSize:Int;
  public var brushColor:Int;

  public var uWidth:Int;
  public var uHeight:Int;

  private var brushFactory:BrushFactory;

  public var currentTool:ITool;
  public var previousTool:ITool;

  public function new(width:Int, height:Int, brushFactory:BrushFactory, currentTool:ITool) {
    super();

    this.brushFactory = brushFactory;

    uWidth = width;
    uHeight = height;

    zoom = 1;

    brushSize = 5;
    brushColor = 0x000000;

    data = new BitmapData(width, height);
    undoSteps = new Array<BitmapData>();
    redoSteps = new Array<BitmapData>();
    maxUndoSteps = 5;

    display = new Bitmap(data);
    display.smoothing = false;

    grid = new Shape();
    grid.visible = false;
    var gfx = grid.graphics;
    gfx.lineStyle(1, 0x444444, 1, false, LineScaleMode.NONE);
    for (y in 0...height + 1) {
      gfx.moveTo(0, y);
      gfx.lineTo(width, y);
    }
    for (x in 0...width + 1) {
      gfx.moveTo(x, 0);
      gfx.lineTo(x, height);
    }

    addChild(display);

    addChild(grid);

    lastMousePoint = new Point(-1, -1);
    //zoomPoint = new Point(this.x + width / 2, this.y + height / 2);
    //zoomPoint = new Point(this.x + width, this.y + height);
    zoomPoint = localToGlobal(new Point(width / 2, height / 2));

    this.currentTool = currentTool;

    addEventListener(MouseEvent.MOUSE_DOWN, onClick);
    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }

  public function moveTo(x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    zoomPoint = localToGlobal(new Point(width / 2, height / 2));
    //zoomPoint.x = this.x + this.width / 2;
    //zoomPoint.y = this.y + this.height / 2;
  }

  //
  // Drawing functions
  //
  public function drawDot(x:Int, y:Int) {
    brushFactory.drawBrush(data, x, y);
  }

  // Really bad line drawing. Really.
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

  public function getPoint(x:Int, y:Int):Int {
    return data.getPixel(x, y);
  }

  public function fill(startX:Int, startY:Int, ?color:Int) {
    if (color == null) {
      color = brushFactory.color;
    }

    if (data.getPixel(startX, startY) == color) {
      return;
    }

    data.lock();
    var queue = new List<SimplePoint>();
    var replaceColor:Int = data.getPixel(startX, startY);
    var dirs = [new SimplePoint(1, 0), new SimplePoint(0, 1), new SimplePoint(-1, 0), new SimplePoint(0, -1)];
    var temp:SimplePoint;
    queue.add(new SimplePoint(startX, startY));
    while (queue.length > 0) {
      temp = queue.pop();
      if (temp.x >= 0 && temp.x < data.width && temp.y >= 0 && temp.y < data.height) {
        if (data.getPixel(temp.x, temp.y) == replaceColor) {
          data.setPixel(temp.x, temp.y, color);
          for (dir in dirs) {
            queue.push(new SimplePoint(temp.x + dir.x, temp.y + dir.y));
          }
        }
      }
    }
    data.unlock();
  }

  public function changeZoom(multiplier:Float) {
    zoom *= multiplier;
    if (zoom < 1) {
      zoom = 1;
      return;
    }
    var tempPoint = globalToLocal(zoomPoint);
    var tempX = originalPos.x + (((tempPoint.x) - (tempPoint.x) * multiplier) - (originalPos.x - this.x));
    var tempY = originalPos.y + (((tempPoint.y) - (tempPoint.y) * multiplier) - (originalPos.y - this.y));
    display.scaleX = zoom;
    display.scaleY = zoom;
    grid.scaleX = zoom;
    grid.scaleY = zoom;
    grid.visible = zoom >= 4;
    //this.x = zoomPoint.x - width / 2;
    //this.y = zoomPoint.y - height / 2;
    //Actuate.tween(this, 0.5, {x:tempX, y:tempY});
    //Actuate.tween(display, 0.5, {scaleX: zoom, scaleY:zoom});
    //Actuate.tween(grid, 0.5, {scaleX:zoom, scaleY:zoom});
    this.x = tempX;
    this.y = tempY;
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

  public function getCanvas():BitmapData {
    return data;
  }

  // 
  // Undo stuff
  //
  public function canvasModified():Void {
    if (redoSteps.length > 0) {
      for (i in 0...redoSteps.length) {
        redoSteps.pop();
      }
    }
    undoSteps.push(data.clone());
    if (undoSteps.length > maxUndoSteps) {
      undoSteps.shift();
    }
  }

  public function undoStep():Void {
    if (undoSteps.length > 0) {
      var temp = undoSteps.pop();
      redoSteps.push(data.clone());
      data.copyPixels(
          temp, 
          new Rectangle(0, 0, temp.width, temp.height),
          new Point(0,0)
      );
    }
  }

  public function redoStep():Void {
    if (redoSteps.length > 0) {
      var temp = redoSteps.pop();
      undoSteps.push(data.clone());
      data.copyPixels(
          temp, 
          new Rectangle(0, 0, temp.width, temp.height),
          new Point(0,0)
      );
    }
  }

  //
  // Event Handlers
  //
  public function onClick(event:MouseEvent) {
    currentTool.mouseDownAction(this, event);
  }

  public function onMouseMove(event:MouseEvent) {
    currentTool.mouseMoveAction(this, event);
  }

  public function onMouseUp(event:MouseEvent) {
    currentTool.mouseUpAction(this, event);
  }

  private function onMouseOut(event:MouseEvent) {
    currentTool.mouseUpAction(this, event);
  }

}

class SimplePoint {
  public var x:Int;
  public var y:Int;
  public function new(x:Int, y:Int) {
    this.x = x;
    this.y = y;
  }
}
