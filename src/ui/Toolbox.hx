package ui;

import ui.components.SimpleButton;
import ui.components.Button;
import ui.layouts.GridLayout;
import graphics.Color;
import graphics.Tilesheet;
import graphics.TilesheetHelper;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.geom.Rectangle;
import nme.events.MouseEvent;

class Toolbox extends Sprite {
  public var uWidth(default, null):Int;
  public var uHeight(default, null):Int;
  private var columns:Int;
  private var rows:Int;
  private var commonBevel:Int;

  private var buttons:Array<SimpleButton<BitmapData>>;
  private var buttonGroups:Array<Int>;
  // Matches the button's name to the button's index
  private var buttonNames:Hash<Int>;

  private var imageSet:Array<BitmapData>;
  private var background:Shape;

  private var layout:GridLayout;

  public function new(width:Int, height:Int, columns:Int, rows:Int, ?bevel:Int = 0) {
    super();

    buttons = new Array<SimpleButton<BitmapData>>();
    buttonGroups = new Array<Int>();
    buttonNames = new Hash<Int>();

    uWidth = width;
    uHeight = height;
    this.columns = columns;
    this.rows = rows;

    layout = new GridLayout(width - 1, height - 1, columns, rows);

    background = new Shape();
    var gfx = background.graphics;
    gfx.lineStyle(2, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(0, 0, uWidth, uHeight);
    gfx.endFill();
    gfx.lineStyle();
    addChild(background);
  }

  public function setTilesheet(filename:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {
    imageSet = TilesheetHelper.generateBitmapDataFromTilesheet(filename, tilesX, tilesY);
  }

  public function addButton(name:String, action:MouseEvent->Void, image:Int, ?group:Int = 0, ?groupDefault = false) {
    var button = new SimpleButton(imageSet[image]);
    button.borderWidth = 2;
    if (groupDefault) {
      button.state = clicked;
    }

    if (group != 0) {
      button.onClick = function(event:MouseEvent):Void {
        for (i in 0...buttons.length) {
          if (buttons[i] != button) {
            if (buttonGroups[i] == group) {
              buttons[i].state = normal;
            }
          }
        }
        action(event);
      };
      button.stickyState = true;
    } else {
      button.onClick = action;
    }


    addChild(button);
    buttons.push(button);
    layout.addComponent(button);
    buttonGroups.push(group);
    buttonNames.set(name, buttons.length - 1);

  }

  public function doneAdding() {
    layout.pack();
  }

  public function clickButtonByName(name:String):Void {
    clickButton(buttonNames.get(name));
  }

  public function clickButton(buttonIndex:Int):Void {
    var button = buttons[buttonIndex];
    var downEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, false, false, button.width / 2, button.height / 2);
    var upEvent = new MouseEvent(MouseEvent.MOUSE_UP, false, false, button.width / 2, button.height / 2);
    button.dispatchEvent(downEvent);
    button.dispatchEvent(upEvent);
  }

  public function resize(width:Float, height:Float) {
    uWidth = Std.int(width);
    uHeight = Std.int(height);
    layout.resize(width, height);

    var gfx = background.graphics;
    gfx.clear();
    gfx.lineStyle(2, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(0, 0, uWidth, uHeight);
    gfx.endFill();
    gfx.lineStyle();
  }
}
