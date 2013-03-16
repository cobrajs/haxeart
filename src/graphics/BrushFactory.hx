package graphics;

import cobraui.graphics.Color;
import cobraui.graphics.ImageOpts;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.BlendMode;

import nme.geom.ColorTransform;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.geom.Matrix;

import nme.Assets;

class BrushFactory {
  private var brushBitmap:Bitmap;
  private var brushData:BitmapData;
  private var mainColoredBrushData:BitmapData;
  private var alternateColoredBrushData:BitmapData;

  private var currentBrush:Int;
  private var clipRects:Array<Rectangle>;

  public var tileWidth:Int;
  public var tileHeight:Int;
  public var tilesX:Int;
  public var tilesY:Int;

  public var mainColor:Color;
  public var alternateColor:Color;

  public function new(brushFile:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {

    brushBitmap = new Bitmap(Assets.getBitmapData("assets/" + brushFile));
    brushData = new BitmapData(Math.floor(brushBitmap.width), Math.floor(brushBitmap.height));

    // Setup main and alternate brush data holders
    mainColoredBrushData = new BitmapData(brushData.width, brushData.height);
    mainColoredBrushData.fillRect(new Rectangle(0, 0, brushData.width, brushData.height), Color.transparent);
    alternateColoredBrushData = new BitmapData(brushData.width, brushData.height);
    alternateColoredBrushData.fillRect(new Rectangle(0, 0, brushData.width, brushData.height), Color.transparent);
    brushData.draw(brushBitmap);

    mainColor = new Color(0x000000);
    alternateColor = new Color(0xFFFFFF);

    if (transparentKey != null) {
      ImageOpts.keyBitmapData(brushData, transparentKey);
    }
    updateBrushData();

    currentBrush = Registry.prefs.lastUsedBrush;
    clipRects = new Array<Rectangle>();

    tileWidth = Math.floor(brushData.width / tilesX);
    tileHeight = Math.floor(brushData.height / tilesY);
    this.tilesX = tilesX;
    this.tilesY = tilesY;

    for (y in 0...tilesY) {
      for (x in 0...tilesX) {
        clipRects.push(new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight));
      }
    }
  }

  public function changeColor(mainColor:Int, ?alternateColor:Int) {
    this.mainColor.colorInt = mainColor;
    updateBrushData();
  }

  public function updateBrushData() {
    mainColoredBrushData.draw(
      brushData,
      null,
      Color.generateTransform(this.mainColor.colorInt)
    );
    alternateColoredBrushData.draw(
      brushData,
      null,
      Color.generateTransform(this.alternateColor.colorInt)
    );
  }

  public function swapColors() {
    var tempColorInt:Int = mainColor.colorInt;
    changeColor(alternateColor.colorInt);
    alternateColor.colorInt = tempColorInt;
    updateBrushData();
  }

  public function drawBrush(canvas:BitmapData, x:Int, y:Int, ?brush:Int, ?useAlternateColor:Bool = false):Void {
    canvas.copyPixels(
      useAlternateColor ? alternateColoredBrushData : mainColoredBrushData, 
      clipRects[brush != null ? brush : currentBrush], 
      new Point(x - Math.floor(tileWidth / 2), y - Math.floor(tileHeight / 2)),
      null,
      null,
      true
    );
  }

  // Checks to see if the current brush's color matches a similar pattern
  // on the canvas
  public function checkPoint(canvas:BitmapData, x:Int, y:Int, ?brush:Int):Bool {
    var clipRect = clipRects[brush != null ? brush : currentBrush];
    var xCanvas = x - Math.floor(tileWidth / 2);
    var yCanvas = y - Math.floor(tileHeight / 2);
    var xBrush = Std.int(clipRect.x);
    var yBrush = Std.int(clipRect.y);
    var width = Std.int(clipRect.width);
    var height = Std.int(clipRect.height);

    var good = true;

    canvas.lock();
    mainColoredBrushData.lock();
    for (ty in 0...height) {
      for (tx in 0...width) {
        if (Color.getAlpha(mainColoredBrushData.getPixel32(xBrush + tx, yBrush + ty)) != 0 && (mainColoredBrushData.getPixel(xBrush + tx, yBrush + ty) != canvas.getPixel(xCanvas + tx, yCanvas + ty))) {
          good = false;
        }
      }
    }
    mainColoredBrushData.unlock();
    canvas.unlock();

    return good;
  }

  public function drawBrushScale(canvas:BitmapData, x:Int, y:Int, ?brush:Int, ?scale:Int = 1):Void {
    var tempTileNum = brush != null ? brush : currentBrush;
    var tempTileX = Math.floor(tempTileNum % tilesX);
    var tempTileY = Math.floor(tempTileNum / tilesX);
    var tempBrushRect = clipRects[tempTileNum];
    var tempX = x - (tileWidth * scale) / 2;
    var tempY = y - (tileHeight * scale) / 2;
    canvas.draw(
      mainColoredBrushData,
      new Matrix(scale, 0, 0, scale, tempX - tempTileX * tempBrushRect.width * scale, tempY - tempTileY * tempBrushRect.height * scale),
      null,
      null,
      new Rectangle(tempX, tempY, tempBrushRect.width * scale, tempBrushRect.height * scale), 
      false
    );
  }

  public function getBrushImage():BitmapData {
    var ret = new BitmapData(tileWidth, tileHeight);
    ret.fillRect(new Rectangle(0, 0, ret.width, ret.height), Color.transparent);
    ret.copyPixels(
      mainColoredBrushData,
      clipRects[currentBrush],
      new Point(0, 0),
      null,
      null,
      true
    );
    return ret;
  }

  public function changeBrush(newBrush:Int):Void {
    currentBrush = newBrush;
    Registry.prefs.lastUsedBrush = newBrush;
  }
}

