package ui;

import cobraui.components.Container;
import cobraui.components.SimpleButton;
import cobraui.layouts.GridLayout;
import cobraui.graphics.Color;
import cobraui.graphics.Tilesheet;

import graphics.TilesheetHelper;
import ui.StatusBox;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import openfl.Assets;

class Toolbox extends Container {
  private var columns:Int;
  private var rows:Int;
  private var commonBevel:Int;

  private var statusBox:StatusBox;
  public var buttons:Array<SimpleButton<BitmapData>>;
  private var buttonGroups:Array<Int>;
  // Matches the button's name to the button's index
  private var buttonNames:Map<String,Int>;

  private var imageSet:Array<BitmapData>;
  private var backgroundImg:Shape;

  public function new(width:Int, height:Int, columns:Int, rows:Int) {
    super();

    buttons = new Array<SimpleButton<BitmapData>>();
    buttonGroups = new Array<Int>();
    buttonNames = new Map<String,Int>();

    uWidth = width;
    uHeight = height;
    this.columns = columns;
    this.rows = rows;

    layout = new GridLayout(width - 1, height - 1, columns, rows);

    backgroundImg = new Shape();
    renderBackground();
    addChild(backgroundImg);
  }

  override public function redraw() {
    super.redraw();
    if (ready) {
      renderBackground();
    }
  }

  public function resizeGrid(sizeX:Int, sizeY:Int) {
    var tempLayout = cast(layout, GridLayout);
    tempLayout.sizeX = sizeX;
    tempLayout.sizeY = sizeY;
    tempLayout.pack();
  }

  public function setTilesheet(filename:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {
    imageSet = TilesheetHelper.generateBitmapDataFromTilesheet(filename, tilesX, tilesY);
  }

  public function addButtonLike(button:SimpleButton<BitmapData>) {
    addChild(button);
    layout.addComponent(button);
  }

  public function addButton(name:String, action:MouseEvent->Void, image:Int, ?group:Int = 0, ?groupDefault = false) {
    var button = new SimpleButton(imageSet[image]);
    if (groupDefault) {
      button.flagged = true;
    }

    if (group != 0) {
      button.onClick = function(event:MouseEvent):Void {
        button.flagged = true;
        for (i in 0...buttons.length) {
          if (buttons[i] != button) {
            if (buttonGroups[i] == group) {
              buttons[i].flagged = false;
            }
          }
        }
        action(event);
      };
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

  /*
  public function resize(width:Float, height:Float) {
    uWidth = Std.int(width);
    uHeight = Std.int(height);
    layout.resize(width, height);

    renderBackground();
  }
  */

  private function renderBackground() {
    var gfx = backgroundImg.graphics;
    gfx.clear();
    gfx.lineStyle(2, 0x555555);
    gfx.beginFill(0xAAAAAA);
    gfx.drawRect(0, 0, uWidth, uHeight);
    gfx.endFill();
    gfx.lineStyle();
  }
}
