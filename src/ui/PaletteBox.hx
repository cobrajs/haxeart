package ui;

import ui.ScrollBox;
import ui.components.SimpleButton;
import ui.layouts.GridLayout;

import graphics.Color;

import nme.display.Sprite;
import nme.events.MouseEvent;

class PaletteBox extends ScrollBox {
  private var columns:Int;
  private var rows:Int;

  private var clickFunction:Int->Void;

  public var uWidth:Int;
  public var uHeight:Int;
  
  private var layout:GridLayout;

  public function new(width:Int, height:Int,  columns:Int, rows:Int, clickFunction:Int->Void) {
    super(width, height, 5);

    this.columns = columns;
    this.rows = rows;

    this.clickFunction = clickFunction;

    var gfx = this.graphics;
    gfx.beginFill(0x000000);
    gfx.drawRect(0, 0, width, height);
    gfx.endFill();

    layout = new GridLayout(width, height, columns, rows);
    
    uWidth = width;
    uHeight = height;
  }

  public function addColor(color:Int) {
    var colorBox = new SimpleButton<String>("");
    colorBox.background = new Color(color);
    colorBox.onClick = function(e:MouseEvent) {
      clickFunction(color);
    };

    layout.addComponent(colorBox);
    scrollBox.addChild(colorBox);
  }

  public function doneAdding() {
    layout.pack();
  }

}
