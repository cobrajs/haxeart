package graphics;

import graphics.Color;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.geom.ColorTransform;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.Assets;

class BrushFactory {
  private var brushBitmap:Bitmap;
  private var brushData:BitmapData;
  private var coloredBrushData:BitmapData;

  private var currentBrush:Int;
  private var clipRects:Array<Rectangle>;

  private var tileWidth:Int;
  private var tileHeight:Int;

  public function new(brushFile:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {

    brushBitmap = new Bitmap(Assets.getBitmapData("assets/" + brushFile));
    //brushData = Assets.getBitmapData("assets/" + brushFile);
    brushData = new BitmapData(Math.floor(brushBitmap.width), Math.floor(brushBitmap.height));
    coloredBrushData = new BitmapData(brushData.width, brushData.height);
    coloredBrushData.fillRect(new Rectangle(0, 0, brushData.width, brushData.height), Color.transparent);
    brushData.draw(brushBitmap);

    if (transparentKey != null) {
      Color.keyImage(brushData, transparentKey);
    }
    coloredBrushData.draw(brushData);

    currentBrush = 11;
    clipRects = new Array<Rectangle>();

    tileWidth = Math.floor(brushData.width / tilesX);
    tileHeight = Math.floor(brushData.height / tilesY);

    for (y in 0...tilesY) {
      for (x in 0...tilesX) {
        clipRects.push(new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight));
      }
    }
  }

  public function changeColor(color:Int) {
    coloredBrushData.draw(
      brushData,
      null,
      Color.generateTransform(color)
    );
  }

  public function drawBrush(canvas:BitmapData, x:Int, y:Int):Void {
    canvas.copyPixels(
      coloredBrushData, 
      clipRects[currentBrush], 
      new Point(x - tileWidth / 2, y - tileHeight / 2),
      null,
      null,
      true
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
}

