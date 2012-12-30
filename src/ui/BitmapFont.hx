package ui;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.Graphics;
import nme.geom.Matrix;
import nme.geom.ColorTransform;
import nme.display.Shape;

import nme.Assets;


import graphics.TilesheetHelper;


class BitmapFont {
  public var data:Tilesheet;
  public var fontWidth:Int;
  public var fontHeight:Int;
  public var startsAt:Int;
  
  /*
     Creates a new instance of BitmapFont
     @param fileName Name of the image to use
     @param tilesX   Number of tiles in the X dimension
     @param tilesY   Number of tiles in the Y dimension
     @param startsAt Starting ascii code in the image file 
     */
  public function new(fileName:String, tilesX:Int, tilesY:Int, ?startsAt:Int = 0) {
    var tempData = Assets.getBitmapData("assets/" + fileName);
    data = TilesheetHelper.generateTilesheetFromBitmap(tempData, tilesX, tilesY);
    fontWidth = Math.floor(tempData.width / tilesX);
    fontHeight = Math.floor(tempData.height / tilesY);
    this.startsAt = startsAt;
  }

  public function drawText(canvas:Graphics, x:Int, y:Int, string:String) {
    var drawArray = new Array<Float>();
    for (i in 0...string.length) {
      drawArray.push(x + i * fontWidth);
      drawArray.push(y);
      drawArray.push(startsAt + string.charCodeAt(i));
    }
    data.drawTiles(canvas, drawArray);
  }

  public function drawTextBitmap(bitmapData:BitmapData, x:Int, y:Int, string:String) {
    var draw = new Shape();
    drawText(draw.graphics, x, y, string);
    bitmapData.draw(draw, new Matrix(1, 0, 0, 1, x, y), new ColorTransform(1, 1, 1, 1, 0, 0, 0));
  }
}