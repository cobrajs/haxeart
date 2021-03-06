package ui;

// Project Files
import cobraui.graphics.Color;
import graphics.BrushFactory;
import util.LineIter;
import tools.ITool;
import Registry;

// NME stuffs
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.LineScaleMode;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.ui.Multitouch;

class Canvas extends Sprite {
  private var undoSteps:Array<BitmapData>;
  private var redoSteps:Array<BitmapData>;
  private var data:BitmapData;
  private var display:Bitmap;
  private var grid:Shape;
  private var zoomDisplayData:BitmapData;
  private var zoomDisplay:Bitmap;
  
  public var originalPos:Point;
  public var centerPos:Point;

  private var tempData:BitmapData;
  private var tempDisplay:Bitmap;
  private var modifiedCanvas:Bool;
  private var drawCanceled:Bool;

  public var zoomRect:Rectangle;
  private var lastMousePoint:Point;

  public var zoom:Float;

  public var brushSize:Int;

  public var uWidth:Int;
  public var uHeight:Int;

  private var brushFactory:BrushFactory;

  public var currentTool:ITool;
  public var previousTool:ITool;

  public var mainColor (get, null):Int;
  public var alternateColor (get, null):Int;

  public var ignoreMouse:Bool;

  public var oldZoom:Float;
  public var oldPos:Point;
  
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

    originalPos = new Point(0, 0);
    centerPos = new Point(0, 0);

    zoom = 1;
    oldZoom = 1;

    brushSize = 5;

    data = new BitmapData(width, height);
    tempData = new BitmapData(width, height, true);
    undoSteps = new Array<BitmapData>();
    redoSteps = new Array<BitmapData>();

    modifiedCanvas = false;
    drawCanceled = false;

    display = new Bitmap(data);
    display.smoothing = false;

    tempDisplay = new Bitmap(tempData);
    tempDisplay.smoothing = false;

    grid = new Shape();
    grid.visible = false;
    renderGrid();

    addChild(display);
    addChild(tempDisplay);
    addChild(grid);

    zoomRect = new Rectangle(0, 0, Registry.stageWidth, Registry.stageHeight);
    lastMousePoint = new Point(-1, -1);

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
      addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
    } else {
      addEventListener(MouseEvent.MOUSE_DOWN, onClick);
      addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

  }

  public function loadFromData(imageData:BitmapData) {
    uWidth = imageData.width;
    uHeight = imageData.height;

    display.scaleX = 1;
    display.scaleY = 1;
    tempDisplay.scaleX = 1;
    tempDisplay.scaleY = 1;
    grid.scaleX = 1;
    grid.scaleY = 1;
    zoom = 1;

    data = new BitmapData(imageData.width, imageData.height);
    data.draw(imageData);

    display.bitmapData = data;
    undoSteps = new Array<BitmapData>();
    redoSteps = new Array<BitmapData>();

    renderGrid();

    centerCanvas();
  }

  public function newImage(width:Int, height:Int) {
    uWidth = width;
    uHeight = height;

    display.scaleX = 1;
    display.scaleY = 1;
    tempDisplay.scaleX = 1;
    tempDisplay.scaleY = 1;
    grid.scaleX = 1;
    grid.scaleY = 1;
    zoom = 1;

    data = new BitmapData(width, height);
    tempData = new BitmapData(width, height);

    display.bitmapData = data;
    undoSteps = new Array<BitmapData>();
    redoSteps = new Array<BitmapData>();

    renderGrid();

    centerCanvas();
  }


  private function renderGrid() {
    var gfx = grid.graphics;
    gfx.clear();
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

  public function checkBounds() {
    if (this.x < zoomRect.x - (uWidth * zoom) + zoom) {
      this.x = zoomRect.x - (uWidth * zoom) + zoom;
    } else if (this.x > zoomRect.x + zoomRect.width - zoom) {
      this.x = zoomRect.x + zoomRect.width - zoom;
    }
    if (this.y < zoomRect.y - (uHeight * zoom) + zoom) {
      this.y = zoomRect.y - (uHeight * zoom) + zoom;
    } else if (this.y > zoomRect.y + zoomRect.height - zoom) {
      this.y = zoomRect.y + zoomRect.height - zoom;
    }
  }

  public function moveTo(x:Float, y:Float, ?updateCenter:Bool = true):Void {
    this.x = x;
    this.y = y;

    checkBounds();

    if (updateCenter) {
      setCenter();
    }
  }

  public function moveBy(x:Float, y:Float, ?updateCenter:Bool = true):Void {
    moveTo(this.x + x, this.y + y);
  }

  //
  // Drawing functions
  //
  public function drawDot(x:Int, y:Int, ?useAlternateColor:Bool = false) {
    brushFactory.drawBrush(tempData, x, y, null, useAlternateColor);
    modifiedCanvas = true;
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

  public function checkPoint(x:Int, y:Int):Bool {
    // TESTING //
    return brushFactory.checkPoint(data, x, y);
  }

  public function getPoint(x:Int, y:Int):Int {
    return data.getPixel(x, y);
  }

  public function fill(startX:Int, startY:Int, ?color:Int) {
    if (color == null) {
      color = brushFactory.mainColor.colorInt;
    }

    if (data.getPixel(startX, startY) == color) {
      return;
    }

    data.lock();
    tempData.lock();
    var queue = new List<SimplePoint>();
    var replaceColor:Int = data.getPixel(startX, startY);
    var dirs = [new SimplePoint(1, 0), new SimplePoint(0, 1), new SimplePoint(-1, 0), new SimplePoint(0, -1)];
    var temp:SimplePoint;
    queue.add(new SimplePoint(startX, startY));
    while (queue.length > 0) {
      temp = queue.pop();
      if (temp.x >= 0 && temp.x < data.width && temp.y >= 0 && temp.y < data.height) {
        if (cast(data.getPixel(temp.x, temp.y), Int) == replaceColor && 
            cast(tempData.getPixel(temp.x, temp.y), Int) != color) {
          tempData.setPixel(temp.x, temp.y, color);
          for (dir in dirs) {
            queue.push(new SimplePoint(temp.x + dir.x, temp.y + dir.y));
          }
        }
      }
    }
    data.unlock();
    tempData.unlock();
    modifiedCanvas = true;
  }

  public function quickView() {
    if (oldPos == null) {
      storeState();
      changeZoom(1 / zoom, true);
      centerCanvas();
    }
    else {
      restoreState();
    }
  }

  private function storeState() {
    oldZoom = zoom;
    oldPos = new Point(this.x, this.y);
  }
  
  private function restoreState() {
    zoom = 1;
    changeZoom(oldZoom, true);
    moveTo(oldPos.x, oldPos.y);
    oldZoom = 1;
    oldPos = null;
  }

  public function centerCanvas(?updateCenter:Bool = true) {
    moveTo(
      zoomRect.x + (zoomRect.width / 2 - (uWidth * zoom) / 2), 
      zoomRect.y + (zoomRect.height / 2 - (uHeight * zoom) / 2),
      updateCenter
    );
  }

  public function changeZoom(multiplier:Float, ?keepPos:Bool = false) {
    if (!keepPos) {
      oldPos = null;
    }
    if (multiplier == 1) {
      return;
    }
    if (multiplier < 1 && zoom == 1) {
      return;
    } else if (multiplier > 1 && zoom == 128) {
      return;
    }
    if (zoom < 1 || zoom * multiplier < 1) {
      zoom = 1;
    } else if (zoom > 128 || zoom * multiplier > 128) {
      zoom = 128;
    } else {
      zoom *= multiplier;
    }
    var tempPointGlobal = new Point(zoomRect.x + zoomRect.width / 2, zoomRect.y + zoomRect.height / 2);
    var tempPoint = globalToLocal(tempPointGlobal);
    var tempX = originalPos.x + ((tempPoint.x - tempPoint.x * multiplier) - (originalPos.x - this.x));
    var tempY = originalPos.y + ((tempPoint.y - tempPoint.y * multiplier) - (originalPos.y - this.y));
    display.scaleX = zoom;
    display.scaleY = zoom;
    tempDisplay.scaleX = zoom;
    tempDisplay.scaleY = zoom;
    grid.scaleX = zoom;
    grid.scaleY = zoom;
    grid.visible = zoom >= 8;
    moveTo(tempX, tempY);
  }

  public function centerishCanvas() {
    /*
    trace("Center-ish-ing");
    trace(centerPos.x * zoomRect.width, centerPos.y * zoomRect.height);
    trace(
      centerPos.x * zoomRect.width + (zoomRect.x + (zoomRect.width / 2)), 
      centerPos.y * zoomRect.height + (zoomRect.y + (zoomRect.height / 2)) 
    );
    */

    moveTo(
      (zoomRect.x + (zoomRect.width / 2)) - centerPos.x * zoomRect.width, 
      (zoomRect.y + (zoomRect.height / 2)) - centerPos.y * zoomRect.height, 
      false
    );
  }

  public function setCenter() {
    centerPos.x = Math.floor((zoomRect.x + (zoomRect.width / 2) - x) / zoomRect.width * 10) / 10;
    centerPos.y = Math.floor((zoomRect.y + (zoomRect.height / 2) - y) / zoomRect.height * 10) / 10;

    /*
    trace("Setting center");
    trace(centerPos.x, centerPos.y);
    trace(x, y);
    trace(x - zoomRect.x + (zoomRect.width / 2), y - zoomRect.y + (zoomRect.height / 2));

    moveTo(
      zoomRect.x + (zoomRect.width / 2 - (uWidth * zoom) / 2), 
      zoomRect.y + (zoomRect.height / 2 - (uHeight * zoom) / 2)
    );
    */
  }

  //
  // Getters for color
  //

  public function get_mainColor():Int {
    return brushFactory.mainColor.colorInt;
  }

  public function get_alternateColor():Int {
    return brushFactory.alternateColor.colorInt;
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

  //
  // Canvas modification
  //
  public function clearCanvas(?color:Int = 0xFFFFFF) {
    data.fillRect(new Rectangle(0, 0, data.width, data.height), Color.getARGB(color, 0xFF));
  }

  public function getCanvas():BitmapData {
    return data;
  }

  public function cancelDraw() {
    drawCanceled = true;
    tempData.fillRect(new Rectangle(0, 0, data.width, data.height), 0xFFFFFF00);
    modifiedCanvas = false;
  }

  public function finishDraw() {
    if (modifiedCanvas && !drawCanceled) {
      data.copyPixels(tempData, new Rectangle(0, 0, data.width, data.height), new Point(0, 0), null, null, true);
      tempData.fillRect(new Rectangle(0, 0, data.width, data.height), 0xFFFFFF);
    }
    modifiedCanvas = false;
    drawCanceled = false;
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
    if (undoSteps.length > Registry.prefs.undoSteps) {
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
    if (currentTool.modifiesCanvas()) {
      modifiedCanvas = true;
    }
  }

  public function onMouseMove(event:MouseEvent) {
    currentTool.mouseMoveAction(this, event);
  }

  public function onMouseUp(event:MouseEvent) {
    currentTool.mouseUpAction(this, event);
    if (currentTool.modifiesCanvas()) {
      finishDraw();
    }
  }

  private function onMouseOut(event:MouseEvent) {
    currentTool.mouseUpAction(this, event);
  }

  private function onTouchOut(event:TouchEvent) {
    currentTool.mouseUpAction(this, cast(event, MouseEvent));
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
        // TODO: Might want to find another way of doing this if I get too annoyed with it
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
