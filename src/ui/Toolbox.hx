package ui;

import ui.components.Button;
import graphics.Color;
import graphics.TilesheetHelper;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.Shape;
import nme.geom.Rectangle;
import nme.events.MouseEvent;


class Toolbox extends Sprite {
  private var uWidth:Int;
  private var uHeight:Int;
  private var columns:Int;
  private var rows:Int;
  private var buttonWidth:Int;
  private var buttonHeight:Int;
  private var commonBevel:Int;

  private var buttons:Array<Button>;
  private var buttonGroups:Array<Int>;
  // Matches the button's name to the button's index
  private var buttonNames:Hash<Int>;

  private var imageSetBitmap:Bitmap;
  private var imageSetBitmapData:BitmapData;
  private var imageSet:Tilesheet;
  private var tileWidth:Int;
  private var tileHeight:Int;

  private var background:Shape;

  public function new(width:Int, height:Int, columns:Int, rows:Int, ?bevel:Int = 0) {
    super();

    buttons = new Array<Button>();
    buttonGroups = new Array<Int>();
    buttonNames = new Hash<Int>();

    uWidth = width;
    uHeight = height;
    this.columns = columns;
    this.rows = rows;

    commonBevel = bevel;

    buttonWidth = Math.floor(width / columns);
    buttonHeight = Math.floor(height / rows);

    background = new Shape();
    addChild(background);
  }

  public function setTilesheet(filename:String, tilesX:Int, tilesY:Int, ?transparentKey:Int) {
    var tempData = Assets.getBitmapData("assets/" + filename);
    tileWidth = Std.int(tempData.width / tilesX);
    tileHeight = Std.int(tempData.height / tilesY);
    imageSet = TilesheetHelper.generateTilesheetFromBitmap(tempData, tilesX, tilesY);
  }

  public function addButton(name:String, action:Button->Void, ?image:Int, ?group:Int = 0, ?groupDefault = false) {
    if (buttons.length >= columns * rows) {
      throw "Adding too many buttons to the toolbox";
    }
    var button = new Button(buttonWidth, buttonHeight, commonBevel, group != 0);
    button.x = buttonWidth * (buttons.length % columns);
    button.y = buttonHeight * Math.floor(buttons.length / columns);
    if (groupDefault) {
      button.changeState(Button.CLICKED);
    }

    if (group != 0) {
      button.clickAction = function(thisButton):Void {
        for (i in 0...buttons.length) {
          if (buttons[i] != button) {
            if (buttonGroups[i] == group) {
              buttons[i].changeState(Button.NORMAL);
            }
          }
        }
        action(button);
      }
    }
    else {
      button.clickAction = action;
    }

    if (image != null) {
      trace(image);
      imageSet.drawTiles(button.drawImage(tileWidth, tileHeight), [0, 0, image]);
    }

    addChild(button);
    buttons.push(button);
    buttonGroups.push(group);
    buttonNames.set(name, buttons.length - 1);

    var gfx = background.graphics;
    gfx.beginFill(0xFFFFFF);
    gfx.drawRect(0, 0, buttonWidth * columns, buttonHeight * Math.ceil(buttons.length / columns));
    gfx.endFill();
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
}
