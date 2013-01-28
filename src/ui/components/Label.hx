package ui.components;

// Get the BitmapFont from the Registry
import Registry;

import nme.display.Sprite;

class Label extends Sprite {
  public var text(default, setText):String;
  public var margin(default, setMargin):Int;
  private var ready:Bool;

  public function new(text:String, ?margin:Int = 0) {
    super();

    ready = false;
    this.text = text;
    this.margin = margin;
    ready = true;
    redraw();
  }

  public function redraw() {
    if (ready) {
      this.graphics.clear();
      Registry.font.drawText(this.graphics, margin, margin, text);
    }
  }

  private function setText(t:String):String {
    text = t;
    redraw();
    return text;
  }

  private function setMargin(m:Int):Int {
    margin = m;
    redraw();
    return margin;
  }

}
