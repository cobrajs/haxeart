package ui.components;

// Get the BitmapFont from the Registry
import Registry;

import ui.components.Component;

import nme.display.Sprite;
import nme.display.BitmapData;

class Label<T> extends Component {
  public var content(default, setContent):T;

  public function new(content:T, ?margin:Int = 0) {
    super();

    this.content = content;
    this.margin = margin;
    redraw();
  }

  private function predraw(){}

  override public function redraw() {
    if (ready) {
      super.redraw();
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
      if (uWidth != width || uHeight != height) {
        resize(width, height);
      }
    }
  }

  private function setContent(t:T):T {
    content = t;
    redraw();
    return content;
  }

  override private function setMargin(m:Int):Int {
    margin = m;
    redraw();
    return margin;
  }

}
