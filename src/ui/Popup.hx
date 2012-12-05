package ui;

import nme.display.Sprite;
import nme.events.MouseEvent;

class Popup extends Sprite {

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
    this.x = popupX;
    this.y = popupY;
    this.visible = true;
  }

  private function onMouseUp(event:MouseEvent) {
    this.visible = false;
  }
}
