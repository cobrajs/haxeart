package ui;

import cobraui.util.ScrollBox;
import cobraui.components.SimpleButton;
import cobraui.layouts.GridLayout;
import cobraui.popup.PopupEvent;

import cobraui.graphics.Color;

import ui.CustomEvents;
import dialog.ColorPicker;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

class PaletteBox extends ScrollBox {
  private static var index:Int = 1;

  private var columns:Int;
  private var rows:Int;

  private var clickFunction:Int->Bool->Void;

  private var colorsHash:Map<Int, SimpleButton<String>>;
  private var colorsIndexHash:Map<Int,Int>;

  private var layout:GridLayout;

  public function new(width:Int, height:Int, clickFunction:Int->Bool->Void) {
    super(width, height, 5);

    this.columns = Registry.prefs.paletteX;
    this.rows = Registry.prefs.paletteY;

    var added = false;
    var addedFunction:Event->Void = null;
    addedFunction = function(e:Event) {
      if (!added) {
        stage.addEventListener(CustomEvents.RESIZE_PALETTE, function(e) {
          this.resizeGrid(Registry.prefs.paletteX, Registry.prefs.paletteY);
        });
        added = true;
        removeEventListener(Event.ADDED_TO_STAGE, addedFunction);
      }
    };
    addEventListener(Event.ADDED_TO_STAGE, addedFunction);

    this.clickFunction = clickFunction;

    layout = new GridLayout(width, height, columns, rows);
    colorsHash = new Map<Int, SimpleButton<String>>();
    colorsIndexHash = new Map<Int,Int>();
    
    uWidth = width;
    uHeight = height;

    renderBackground();
  }

  public function resizeGrid(sizeX:Int, sizeY:Int) {
    columns = sizeX;
    rows = sizeY;
    layout.sizeX = sizeX;
    layout.sizeY = sizeY;
    layout.pack();
    scrollTop();
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
    var index = PaletteBox.index++;
    var colorBox = new SimpleButton<String>("", 1);
    colorBox.borderWidth = 0;
    colorBox.background = new Color(color);
    colorsHash.set(color, colorBox);
    colorsIndexHash.set(index, color);
    colorBox.onClick = function(e:MouseEvent) {
      clickFunction(colorsIndexHash.get(index), true);
      for (box in layout.components) {
        cast(box, SimpleButton<Dynamic>).flagged = false;
      }
      colorBox.flagged = true;
    };
    Registry.clickManager.registerComponent(colorBox, 1, false);
    colorBox.addEventListener(ClickEvent.HOLD_CLICK, function(e:ClickEvent) { 
      var tempColorPicker = new ColorPicker(new Color(colorsIndexHash.get(index)));
      Registry.mainWindow.addChild(tempColorPicker);
      tempColorPicker.popup();
      var id = tempColorPicker.id;
      var msgFnc:PopupEvent->Void = null;
      msgFnc = function(e:PopupEvent) {
        if (e.id == id) {
          if (e.message != "" && e.message != null) {
            var colorInt = Std.parseInt(e.message);
            colorBox.background = new Color(colorInt);
            colorBox.redraw();
            colorsHash.set(colorInt, colorBox);
            colorsIndexHash.set(index, colorInt);
            colorBox.clickButton();
          }
          tempColorPicker.hide();
          stage.removeEventListener(PopupEvent.MESSAGE, msgFnc);
          Registry.mainWindow.removeChild(tempColorPicker);
        }
      };
      stage.addEventListener(PopupEvent.MESSAGE, msgFnc);
    });

    layout.addComponent(colorBox);
    scrollBox.addChild(colorBox);
  }

  public function doneAdding() {
    layout.pack();
  }

  override public function resize(width:Float, height:Float) {
    layout.resize(width, height);

    resizeBox(width, height);

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
