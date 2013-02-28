package ui.components;

// TODO: Add indicator flag and render option for a selected component

import graphics.Color;

import nme.display.Sprite;
import nme.events.Event;
import nme.display.Graphics;

class Component extends Sprite {
  public var uWidth(default, null):Float;
  public var uHeight(default, null):Float;
  public var margin(default, setMargin):Int;
  public var background:Color;
  public var foreground:Color;
  public var border:Color;
  public var borderWidth:Int;
  public var ready:Bool;

  public var predraw:Graphics->Float->Float->Void;

  public function new() {
    super();

    ready = false;
    uWidth = 10;
    uHeight = 10;
    margin = 0;

    background = new Color(0xDDDDDD);
    foreground = new Color(0x000000);
    
    border = new Color(0x777777);
    borderWidth = 0;

    predraw = null;

    addEventListener(Event.ADDED, function(e:Event) {
      ready = true;
      redraw();
    });
  }

  public function resize(width:Float, height:Float) {
    uWidth = width;
    uHeight = height;
    redraw();
  }

  public function redraw() {
    if (ready) {
      var gfx = this.graphics;
      gfx.clear();
      if (predraw != null) {
        predraw(this.graphics, uWidth, uHeight);
      }
      if (background != null) {

        if (borderWidth > 0) {
          gfx.lineStyle(borderWidth, border.colorInt, border.alpha);
        }

        gfx.beginFill(background.colorInt, background.alpha);
        //gfx.drawRect(-borderWidth, -borderWidth, uWidth + (borderWidth * 2), uHeight + (borderWidth * 2));
        //gfx.drawRect(borderWidth, borderWidth, uWidth - (borderWidth * 2), uHeight - (borderWidth * 2));
        gfx.drawRect(0, 0, uWidth, uHeight);
        gfx.endFill();
        gfx.lineStyle();
      }
      else if (borderWidth > 0) {
        gfx.lineStyle(borderWidth, border.colorInt, border.alpha);
        //gfx.drawRect(-borderWidth, -borderWidth, uWidth + (borderWidth * 2), uHeight + (borderWidth * 2));
        //gfx.drawRect(borderWidth, borderWidth, uWidth - (borderWidth * 2), uHeight - (borderWidth * 2));
        gfx.drawRect(0, 0, uWidth, uHeight);
        gfx.lineStyle();
      }
    }
  }

  private function setMargin(margin:Int):Int {
    this.margin = margin;
    redraw();
    return margin;
  }
}
