package ui;

// Actuate
import com.eclecticdesignstudio.motion.Actuate;

// Project Files
import graphics.BrushFactory;
import graphics.Color;
import util.LineIter;
import tools.ITool;
import Registry;

// NME stuffs
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.display.LineScaleMode;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.geom.ColorTransform;
import nme.ui.Multitouch;

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

  public var ignoreMouse:Bool;

  public var oldZoom:Float;
  
  // Touch Gesture stuff
  public var threshold:Int;
  public var originPoint:Point;
  public var allowDraw:Bool;
  public var noTouchUpEvent:Bool;

  public function new(width:Int, height:Int, brushFactory:BrushFactory, currentTool:ITool) {
    super();

    this.brushFactory = brushFactory;

    uWidth = width;
    uHeight = height;

    zoom = 1;
    oldZoom = 1;

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
    renderGrid();

    addChild(display);

    addChild(grid);

    lastMousePoint = new Point(-1, -1);
    //zoomPoint = new Point(this.x + width / 2, this.y + height / 2);
    //zoomPoint = new Point(this.x + width, this.y + height);
    zoomPoint = localToGlobal(new Point(width / 2, height / 2));

    this.currentTool = currentTool;
    ignoreMouse = false;

    threshold = 20;
    originPoint = new Point(0, 0);
    allowDraw = false;

    noTouchUpEvent = false;

    if (Multitouch.supportsTouchEvents) {
      addEventListener(TouchEvent.TOUCH_BEGIN, Registry.touchManager.onTouchBegin);
      addEventListener(TouchEvent.TOUCH_MOVE, Registry.touchManager.onTouchMove);
      addEventListener(TouchEvent.TOUCH_END, Registry.touchManager.onTouchEnd);
      addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
      addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
      addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
      //addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
    }
    else {
      addEventListener(MouseEvent.MOUSE_DOWN, onClick);
      addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

  }

  public function loadFromData(imageData:BitmapData) {
    display.scaleX = 1;
    display.scaleY = 1;
    zoom = 1;

    data = new BitmapData(imageData.width, imageData.height);
    data.draw(imageData);

    display.bitmapData = data;
    undoSteps = new Array<BitmapData>();
    redoSteps = new Array<BitmapData>();

    renderGrid();

    zoomPoint = localToGlobal(new Point(width / 2, height / 2));
  }


  private function renderGrid() {
    var gfx = grid.graphics;
    gfx.lineStyle(1, 0x444444, 1, false, LineScaleMode.NONE);
    for (y in 0...Std.int(uHeight + 1)) {
      gfx.moveTo(0, y);
      gfx.lineTo(uWidth, y);
    }
    for (x in 0...Std.int(uWidth + 1)) {
      gfx.moveTo(x, 0);
      gfx.lineTo(x, uHeight);
    }
  }

  public function moveTo(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;

    /*
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    */

    zoomPoint = localToGlobal(new Point(width / 2, height / 2));
  }

  public function moveBy(x:Float, y:Float):Void {
    moveTo(this.x + x, this.y + y);
    //this.x += x;
    //this.y += y;
    //zoomPoint = localToGlobal(new Point(width / 2, height / 2));
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
        if (cast(data.getPixel(temp.x, temp.y), Int) == replaceColor) {
          data.setPixel(temp.x, temp.y, color);
          for (dir in dirs) {
            queue.push(new SimplePoint(temp.x + dir.x, temp.y + dir.y));
          }
        }
      }
    }
    data.unlock();
  }

  public function quickView() {
    if (Math.abs(1 - zoom) > 0.2) {
      oldZoom = zoom;
      changeZoom(1 / zoom);
    }
    else {
      zoom = 1;
      changeZoom(oldZoom);
      oldZoom = 1;
    }
  }

  public function changeZoom(multiplier:Float) {
    if (multiplier == 1) {
      return;
    }
    if (multiplier < 1 && zoom == 1) {
      return;
    }
    else if (multiplier > 1 && zoom == 128) {
      return;
    }
    if (zoom < 1 || zoom * multiplier < 1) {
      zoom = 1;
    }
    else if (zoom > 128 || zoom * multiplier > 128) {
      zoom = 128;
    }
    else {
      zoom *= multiplier;
    }
    var tempPoint = globalToLocal(zoomPoint);
    var tempX = originalPos.x + (((tempPoint.x) - (tempPoint.x) * multiplier) - (originalPos.x - this.x));
    var tempY = originalPos.y + (((tempPoint.y) - (tempPoint.y) * multiplier) - (originalPos.y - this.y));
    display.scaleX = zoom;
    display.scaleY = zoom;
    grid.scaleX = zoom;
    grid.scaleY = zoom;
    grid.visible = zoom >= 8;
    //this.x = zoomPoint.x - width / 2;
    //this.y = zoomPoint.y - height / 2;
    //Actuate.tween(this, 0.5, {x:tempX, y:tempY});
    //Actuate.tween(display, 0.5, {scaleX: zoom, scaleY:zoom});
    //Actuate.tween(grid, 0.5, {scaleX:zoom, scaleY:zoom});
    moveTo(tempX, tempY);
    //this.x = tempX;
    //this.y = tempY;
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

  private function onTouchBegin(event:TouchEvent) {
    if (Registry.touchManager.touchCount < 2) {
      originPoint.x = event.stageX;
      originPoint.y = event.stageY;
    }
    allowDraw = false;
  }

  private function onTouchMove(event:TouchEvent) {
    if (Registry.touchManager.touchCount <= 1) {
      if (Registry.touchManager.wasZooming) {
        originPoint.x = event.stageX;
        originPoint.y = event.stageY;
        Registry.touchManager.wasZooming = false;
        noTouchUpEvent = true;
      }
      if (allowDraw) {
        currentTool.mouseMoveAction(this, cast(event, MouseEvent));
      }
      else {
        if (Point.distance(originPoint, new Point(event.stageX, event.stageY)) > threshold) {
          allowDraw = true;
          currentTool.mouseDownAction(this, cast(event, MouseEvent));
          currentTool.mouseMoveAction(this, cast(event, MouseEvent));
        }
      }
    }
  }

  private function onTouchEnd(event:TouchEvent) {
    if (Registry.touchManager.touchCount <= 0) {
      if (!allowDraw && Point.distance(originPoint, new Point(event.stageX, event.stageY)) < threshold && !Registry.touchManager.wasZooming && !noTouchUpEvent) {
        currentTool.mouseDownAction(this, cast(event, MouseEvent));
        currentTool.mouseUpAction(this, cast(event, MouseEvent));
      }
      else {
        currentTool.mouseUpAction(this, cast(event, MouseEvent));
      }
      allowDraw = false;
      noTouchUpEvent = false;
    }
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
