package dialog;

// TODO: Make Popup a Component with it's own BorderLayout

import com.eclecticdesignstudio.motion.Actuate;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.Assets;
import nme.events.MouseEvent;

class Popup extends Sprite {

  public var uWidth:Int;
  public var uHeight:Int;

  private var window:Sprite;
  private var closeButton:Sprite;
  private var overlay:Sprite;

  public function new(width:Int, height:Int, ?closeButton:Bool = true) {
    super();

    uWidth = width;
    uHeight = height;

    overlay = new Sprite();
    var gfx = overlay.graphics;
    gfx.beginFill(0x555555, 0.5);
    gfx.drawRect(0, 0, Registry.stageWidth, Registry.stageHeight);
    gfx.endFill();
    addChild(overlay);

    window = new Sprite();
    var offset = 2;
    var gfx = window.graphics;
    gfx.lineStyle(2, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(-offset, -offset, width + offset * 2, height + offset * 2);
    gfx.endFill();
    gfx.lineStyle();
    addChild(window);

    this.visible = false;

    if (closeButton) {
      this.closeButton = new Sprite();
      var tempBitmap = new Bitmap(Assets.getBitmapData("assets/close_button.png"));
      this.closeButton.addChild(tempBitmap);
      this.closeButton.x = width;
      window.addChild(this.closeButton);
    }

    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
  }

  public function popup(?x:Int, ?y:Int) {
    if (x == null) {
      x = Std.int((Registry.stageWidth - window.width) / 2);
    }
    if (y == null) {
      y = Std.int((Registry.stageHeight - uHeight) / 2);
    }
    var popupX = x;
    var popupY = y;
    if (x + uWidth > Registry.stageWidth) {
      popupX = x - uWidth;
    }
    if (y + uHeight > Registry.stageHeight) {
      popupY = y - uHeight;
    }
    // Forget the juiciness stuff for now :P
    /*
    window.x = 0;
    window.y = 0;
    window.scaleX = 0.5;
    window.scaleY = 0.5;
    window.alpha = 0;
    this.visible = true;
    Actuate.tween(window, 0.5, {
      x      : popupX,
      y      : popupY,
      scaleX : 1,
      scaleY : 1,
      alpha  : 1
    }, true);
    */
    window.x = popupX;
    window.y = popupY;
    this.visible = true;
  }

  public function hide():Void {
    /*
    var scale = 1.5;
    Actuate.tween(window, 0.3, {
      x      : x - ((window.width * scale) - window.width) / 2,
      y      : y - ((window.height * scale) - window.height) / 2,
      scaleX : scale,
      scaleY : scale,
      alpha  : 0
    }, true).onComplete(function():Void {
      this.visible = false;
    });
    */
    this.visible = false;
  }

  private function onMouseUp(event:MouseEvent) {
    if (event.target == closeButton) {
      this.visible = false;
    }
  }
}
