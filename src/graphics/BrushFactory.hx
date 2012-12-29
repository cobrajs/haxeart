package graphics;

import graphics.Color;

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
  private var coloredBrushData:BitmapData;

  private var currentBrush:Int;
  private var clipRects:Array<Rectangle>;

  public var tileWidth:Int;
  public var tileHeight:Int;
  public var tilesX:Int;
  public var tilesY:Int;

  public var color:Int;

  public function new(brushFile:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {

    brushBitmap = new Bitmap(Assets.getBitmapData("assets/" + brushFile));
    brushData = new BitmapData(Math.floor(brushBitmap.width), Math.floor(brushBitmap.height));
    coloredBrushData = new BitmapData(brushData.width, brushData.height);
    coloredBrushData.fillRect(new Rectangle(0, 0, brushData.width, brushData.height), Color.transparent);
    brushData.draw(brushBitmap);

    color = 0x000000;

    if (transparentKey != null) {
      Color.keyImage(brushData, transparentKey);
    }
    coloredBrushData.draw(brushData);

    currentBrush = 2;
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

  public function changeColor(color:Int) {
    this.color = color;
    coloredBrushData.draw(
      brushData,
      null,
      Color.generateTransform(color)
    );
  }

  public function drawBrush(canvas:BitmapData, x:Int, y:Int, ?brush:Int):Void {
    canvas.copyPixels(
      coloredBrushData, 
      clipRects[brush != null ? brush : currentBrush], 
      new Point(x - tileWidth / 2, y - tileHeight / 2),
      null,
      null,
      true
    );
  }

  public function drawBrushScale(canvas:BitmapData, x:Int, y:Int, ?brush:Int, ?scale:Int = 1):Void {
    var tempTileNum = brush != null ? brush : currentBrush;
    var tempTileX = Math.floor(tempTileNum % tilesX);
    var tempTileY = Math.floor(tempTileNum / tilesY);
    var tempBrushRect = clipRects[tempTileNum];
    var tempX = x - (tileWidth * scale) / 2;
    var tempY = y - (tileHeight * scale) / 2;
    canvas.draw(
      coloredBrushData,
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
      coloredBrushData,
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
  }
}

