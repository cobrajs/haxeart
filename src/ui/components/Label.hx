package ui.components;

// Get the BitmapFont from the Registry
import Registry;

import nme.display.Sprite;
import nme.display.BitmapData;

class Label<T> extends Sprite {
  public var content(default, setContent):T;
  public var margin(default, setMargin):Int;
  private var ready:Bool;

  public function new(content:T, ?margin:Int = 0) {
    super();

    ready = false;
    this.content = content;
    this.margin = margin;
    ready = true;
    redraw();
  }

  private function predraw(){}

  public function redraw() {
    if (ready) {
      this.graphics.clear();
      predraw();
      if (Std.is(content, String)) { 
        Registry.font.drawText(this.graphics, margin, margin, cast(content, String));
      }
      else if (Std.is(content, BitmapData)) {
        var gfx = this.graphics;
        var temp = cast(content, BitmapData);
        gfx.beginBitmapFill(cast(content, BitmapData));
        gfx.drawRect(0, 0, temp.width, temp.height);
        gfx.endFill();
      }
    }
  }

  private function setContent(t:T):T {
    content = t;
    redraw();
    return content;
  }

  private function setMargin(m:Int):Int {
    margin = m;
    redraw();
    return margin;
  }

}
