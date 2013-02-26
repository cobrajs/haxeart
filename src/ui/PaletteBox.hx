package ui;

import ui.ScrollBox;
import ui.layouts.GridLayout;

import nme.display.Sprite;
import nme.events.MouseEvent;

class PaletteBox extends ScrollBox {
  private var columns:Int;
  private var rows:Int;

  private var colorBoxes:Array<Sprite>;
  private var colorLookups:Array<Int>;

  private var tileHeight:Int;
  private var tileWidth:Int;

  private var clickFunction:Int->Void;

  public var uWidth:Int;
  public var uHeight:Int;
  
  private var layout:GridLayout;

  public function new(width:Int, height:Int,  columns:Int, rows:Int, clickFunction:Int->Void) {
    super(width, height, 5);

    this.columns = columns;
    this.rows = rows;

    colorBoxes = new Array<Sprite>();
    colorLookups = new Array<Int>();

    this.clickFunction = clickFunction;

    var gfx = this.graphics;
    gfx.beginFill(0x000000);
    gfx.drawRect(0, 0, width, height);
    gfx.endFill();

    tileWidth = Math.floor(width / columns);
    tileHeight = Math.floor(height / rows);

    layout = new GridLayout(width, height, columns, rows);
    
    uWidth = width;
    uHeight = height;
  }

  public function addColor(color:Int) {
    var colorBox = new Sprite();
    var gfx = colorBox.graphics;
    gfx.beginFill(color);
    gfx.drawRect(0, 0, tileWidth, tileHeight);
    gfx.endFill();
    colorBox.x = tileWidth * (colorBoxes.length % columns);
    colorBox.y = tileHeight * Math.floor(colorBoxes.length / columns);
    scrollBox.addChild(colorBox);
    colorBoxes.push(colorBox);
    colorLookups.push(color);

    colorBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
  }

  private function mouseDown(event:MouseEvent) {
    var colorBox = cast(event.currentTarget, Sprite);
    for (i in 0...colorBoxes.length) {
      if (colorBox == colorBoxes[i]) {
        clickFunction(colorLookups[i]);
        break;
      }
    }
  }
  
  public function scroll(delta:Int) {
    scrollBox.y += delta * tileHeight;
    if (scrollBox.y > 0) {
      scrollBox.y = 0;
    }
    if (scrollBox.y + scrollBox.height < uHeight) {
      scrollBox.y = uHeight - scrollBox.height;
    }
  }
}
