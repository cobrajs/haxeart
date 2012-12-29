package ui;

import com.eclecticdesignstudio.motion.Actuate;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.Assets;
import nme.events.MouseEvent;

class Popup extends Sprite {

  private var closeButton:Sprite;
  public var uWidth:Int;
  public var uHeight:Int;

  public function new(width:Int, height:Int) {
    super();

    uWidth = width;
    uHeight = height;

    var gfx = this.graphics;
    gfx.lineStyle(3, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(0, 0, width, height);

    this.visible = false;

    closeButton = new Sprite();
    var tempBitmap = new Bitmap(Assets.getBitmapData("assets/close_button.png"));
    closeButton.addChild(tempBitmap);
    closeButton.x = width;
    addChild(closeButton);

    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
  }

  public function popup(x:Int, y:Int) {
    var popupX = x;
    var popupY = y;
    if (x + uWidth > stage.stageWidth) {
      popupX = x - uWidth;
    }
    if (y + uHeight > stage.stageHeight) {
      popupY = y - uHeight;
    }
    this.x = 0;
    this.y = 0;
    this.scaleX = 0.5;
    this.scaleY = 0.5;
    this.alpha = 0;
    this.visible = true;
    Actuate.tween(this, 0.5, {
      x      : popupX,
      y      : popupY,
      scaleX : 1,
      scaleY : 1,
      alpha  : 1
    }, true);
  }

  public function hide():Void {
    var scale = 1.5;
    Actuate.tween(this, 0.3, {
      x      : x - ((this.width * scale) - this.width) / 2,
      y      : y - ((this.height * scale) - this.height) / 2,
      scaleX : scale,
      scaleY : scale,
      alpha  : 0
    }, true).onComplete(function():Void {
      this.visible = false;
    });
  }

  private function onMouseUp(event:MouseEvent) {
    this.visible = false;
  }
}
