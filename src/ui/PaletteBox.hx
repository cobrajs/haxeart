package ui;

import cobraui.util.ScrollBox;
import cobraui.components.SimpleButton;
import cobraui.layouts.GridLayout;

import cobraui.graphics.Color;

import nme.display.Sprite;
import nme.events.MouseEvent;

class PaletteBox extends ScrollBox {
  private var columns:Int;
  private var rows:Int;

  private var clickFunction:Int->Void;

  private var colorsHash:IntHash<SimpleButton<String>>;

  public var uWidth:Int;
  public var uHeight:Int;
  
  private var layout:GridLayout;

  public function new(width:Int, height:Int,  columns:Int, rows:Int, clickFunction:Int->Void) {
    super(width, height, 5);

    this.columns = columns;
    this.rows = rows;

    this.clickFunction = clickFunction;

    layout = new GridLayout(width, height, columns, rows);
    colorsHash = new IntHash<SimpleButton<String>>();
    
    uWidth = width;
    uHeight = height;

    renderBackground();
  }

  private function renderBackground() {
    var gfx = this.graphics;
    gfx.clear();
    gfx.lineStyle(2, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(0, 0, uWidth, uHeight);
    gfx.endFill();
    gfx.lineStyle();
  }

  public function addColor(color:Int) {
    var colorBox = new SimpleButton<String>("");
    colorBox.borderWidth = 0;
    colorBox.background = new Color(color);
    colorsHash.set(color, colorBox);
    colorBox.onClick = function(e:MouseEvent) {
      clickFunction(color);
      for (box in layout.components) {
        cast(box, SimpleButton<Dynamic>).flagged = false;
      }
      colorBox.flagged = true;
    };

    layout.addComponent(colorBox);
    scrollBox.addChild(colorBox);
  }

  public function doneAdding() {
    layout.pack();
  }

  override public function resize(width:Float, height:Float) {
    uWidth = Std.int(width);
    uHeight = Std.int(height);
    layout.resize(width, height);

    super.resize(width, height);

    renderBackground();
  }

  public function pickColor(colorInt:Int) {
    var button = colorsHash.get(colorInt);
    if (button != null) {
      for (box in layout.components) {
        cast(box, SimpleButton<Dynamic>).flagged = false;
      }
      button.flagged = true;
    }
  }

}
