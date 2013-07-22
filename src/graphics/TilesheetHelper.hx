package graphics;

import cobraui.graphics.ImageOpts;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import openfl.display.Tilesheet;
import openfl.Assets;

// TODO: Keeping this around for now, but it is superceded by my Tilesheet override implementation

class TilesheetHelper {
  public static function getTransparentBitmapData(bitmapData:BitmapData):BitmapData {
    var data = new BitmapData(bitmapData.width, bitmapData.height, true);
    data.copyPixels(bitmapData, new Rectangle(0, 0, bitmapData.width, bitmapData.height), new Point(0, 0), null, null, false);
    ImageOpts.keyBitmapData(data);
    return data;
  }

  public static function generateTilesheetFromBitmap(imageData:BitmapData, tilesX:Int, tilesY:Int, ?flippedX:Bool = false, flippedY:Bool = false):Tilesheet {
    var data = getTransparentBitmapData(imageData);

    if (flippedX || flippedY) {
      data = ImageOpts.flipImageData(data, flippedX, flippedY);
    }

    var tilesheet = new Tilesheet(data);

    var tileWidth = Std.int(data.width / tilesX);
    var tileHeight = Std.int(data.height / tilesY);

    var xTransform = flippedX ? function(x){return (tilesX - x - 1) * tileWidth;} : function(x){return x * tileWidth;};
    var yTransform = flippedY ? function(y){return (tilesY - y - 1) * tileHeight;} : function(y){return y * tileHeight;};
    for (y in 0...tilesY) {
      for (x in 0...tilesX) {
        tilesheet.addTileRect(new Rectangle(xTransform(x), yTransform(y), tileWidth, tileHeight));
      }
    }

    return tilesheet;
  }

  public static function generateTilesheet(imageName:String, tilesX:Int, tilesY:Int, ?flippedX:Bool = false, ?flippedY:Bool = false):Tilesheet {
    var tempData = Assets.getBitmapData("assets/" + imageName);
    return generateTilesheetFromBitmap(tempData, tilesX, tilesY, flippedX, flippedY);
  }

  public static function generateBitmapDataFromTilesheet(imageName:String, tilesX:Int, tilesY:Int):Array<BitmapData> {
    var tempData = getTransparentBitmapData(Assets.getBitmapData("assets/" + imageName));

    var tileWidth = Std.int(tempData.width / tilesX);
    var tileHeight = Std.int(tempData.height / tilesY);

    var returnData = new Array<BitmapData>();

    for (y in 0...tilesY) {
      for (x in 0...tilesX) {
        var tempBitmapData = new BitmapData(tileWidth, tileHeight, true);
        tempBitmapData.copyPixels(tempData, new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight), new Point(0, 0), null, null, false);
        returnData.push(tempBitmapData);
      }
    } 
    
    return returnData;
  }

}
