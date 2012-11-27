package ui;

import ui.Button;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;

class Toolbox extends Sprite {
  private var uWidth:Int;
  private var uHeight:Int;
  private var columns:Int;
  private var rows:Int;
  private var buttonWidth:Int;
  private var buttonHeight:Int;
  private var commonBevel:Int;

  private var buttons:Array<Button>;

  private var imageSetBitmap:Bitmap;
  private var imageSetBitmapData:BitmapData;
  private var imageSet:Tilesheet;
  private var tileWidth:Int;
  private var tileHeight:Int;

  public function new(width:Int, height:Int, columns:Int, rows:Int, ?bevel:Int = 0) {
    super();

    buttons = new Array<Button>();
    uWidth = width;
    uHeight = height;
    this.columns = columns;
    this.rows = rows;

    commonBevel = bevel;

    buttonWidth = Math.floor(width / columns);
    buttonHeight = Math.floor(height / rows);
  }

  public function setTilesheet(filename:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {
    try {
      imageSetBitmap = new Bitmap(Assets.getBitmapData("assets/" + filename));
      imageSetBitmapData = new BitmapData(Math.floor(imageSetBitmap.width), Math.floor(imageSetBitmap.height));
      imageSetBitmapData.draw(imageSetBitmap);

      if (transparentKey != null) {
        imageSetBitmapData.lock();
        for (y in 0...cast(imageSetBitmap.height, Int)) {
          for (x in 0...cast(imageSetBitmap.width, Int)) {
            if (imageSetBitmapData.getPixel(x, y) == transparentKey) {
#if neko
              imageSetBitmapData.setPixel32(x, y, {rgb: 0, a: 0});
#else
              imageSetBitmapData.setPixel32(x, y, 0x00000000);
#end
            }
          }
        }
        imageSetBitmapData.unlock();
      }

      imageSet = new Tilesheet(imageSetBitmapData);

      tileWidth = Math.floor(imageSetBitmap.width / tilesX);
      tileHeight = Math.floor(imageSetBitmap.height / tilesY);

      for (y in 0...tilesY) {
        for (x in 0...tilesX) {
          imageSet.addTileRect(new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight));
        }
      }
    }
    catch(e:Dynamic) {
      throw "Error setting up tilesheet: " + e;
    }
  }

  public function addButton(action:Void->Void, ?image:Int) {
    var button = new Button(buttonWidth, buttonHeight, commonBevel);
    button.x = buttonWidth * (buttons.length % columns);
    button.y = buttonHeight * Math.floor(buttons.length / columns);
    button.clickAction = action;
    if (image != null) {
      imageSet.drawTiles(button.drawImage(tileWidth, tileHeight), [0, 0, image]);
    }
    addChild(button);
    buttons.push(button);
  }
}
