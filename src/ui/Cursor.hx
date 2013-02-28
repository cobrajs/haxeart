package ui;

import graphics.Color;

import nme.display.Sprite;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.ui.Mouse;
import nme.geom.Rectangle;
import nme.geom.Matrix;

class Cursor extends Sprite {
  private var image:Sprite;

  private var images:Hash<BitmapData>;
  private var useZoom:Hash<Bool>;

  private var zoomLevel:Float;

  public var currentCursor:String;

  public function new(?width:Int = 9, ?height:Int = 9) {
    super();
#if !mobile

    images = new Hash<BitmapData>();
    useZoom = new Hash<Bool>();

    image = new Sprite();
    addChild(image);
    image.x = -Math.ceil(width / 2);
    image.y = -Math.ceil(height / 2);
    image.mouseEnabled = false;

    var imageBitmapData = new BitmapData(width, height);
    imageBitmapData.fillRect(new Rectangle(0,0, imageBitmapData.width, imageBitmapData.height),  Color.transparent);
    imageBitmapData.fillRect(new Rectangle(0, 1, imageBitmapData.width, imageBitmapData.height - 2), Color.getARGB(0x000000, 0xFF));
    imageBitmapData.fillRect(new Rectangle(1, 0, imageBitmapData.width - 2, imageBitmapData.height), Color.getARGB(0x000000, 0xFF));

    addTypeCursor("default", imageBitmapData, false);
    setCursor("default");

    this.x = 0;
    this.y = 0;
    this.visible = true;
    this.zoomLevel = 1;
    this.mouseEnabled = false;
    //Mouse.hide();
#end
  } 

  public function addTypeCursor(name:String, imageData:BitmapData, ?useZoom:Bool = false) {
#if !mobile
    images.set(name, imageData);
    this.useZoom.set(name, useZoom);
#end
  }

  public function updateTypeCursor(name:String, imageData:BitmapData) {
#if !mobile
    images.set(name, imageData);
    if (name == currentCursor) {
      setCursor(name, imageData);
    }
#end
  }

  public function setCursor(name:String, ?imageData:BitmapData) {
#if !mobile
    if (imageData == null && (currentCursor == name || !images.exists(name))) {
      return;
    }

    currentCursor = name;

    if (useZoom.get(currentCursor)) {
      this.scaleX = this.zoomLevel;
      this.scaleY = this.zoomLevel;
    }
    else {
      this.scaleX = 1;
      this.scaleY = 1;
    }

    var bitmapData = imageData == null ? images.get(name) : imageData;
    var gfx = image.graphics;
    gfx.clear();
    var drawX = Math.floor(bitmapData.width / 2);
    var drawY = Math.floor(bitmapData.height / 2);
    gfx.beginBitmapFill(bitmapData);
    gfx.drawRect(0, 0, bitmapData.width, bitmapData.height);
    gfx.endFill();
#end
  }

  public function update(x:Float, y:Float) {
#if !mobile
    this.x = Math.ceil((x + 1 - (Registry.canvas.x % this.scaleX)) / this.scaleX) * this.scaleX  + (Registry.canvas.x % this.scaleX);
    this.y = Math.ceil((y + 1 - (Registry.canvas.y % this.scaleY)) / this.scaleY) * this.scaleY  + (Registry.canvas.y % this.scaleY);
#end
  }

  public function changeZoom(zoom:Int) {
#if !mobile
    this.zoomLevel = zoom;
    if (useZoom.get(currentCursor)) {
      this.scaleX = this.zoomLevel;
      this.scaleY = this.zoomLevel;
    }
#end
  }
}
