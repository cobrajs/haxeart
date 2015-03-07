package ;

// TODO: Fill in README.md
// TODO: Add palette modification popup
// TODO: Fix rotation of canvas
// TODO: Move double click movement out to main instead of being in the pencil tool
// TODO: Add configuration option to allow putting palette and toolbox on sides
// TODO: Add temp layer that will store data before committing to canvas
// TODO: Add toolbox alternate view with alternate state/icon/action for every button
// TODO: Add toolbox items for shifting, rotating, and flipping canvas
// TODO: Fix fill tool
// TODO: Fix issue with temp layer and loading images
// TODO: Fix issue with grid not displaying right

// CobraUI Elements
import cobraui.components.Component;
import cobraui.components.Label;
import cobraui.components.LabeledComponent;
import cobraui.components.SimpleButton;
import cobraui.layouts.BorderLayout;

import cobraui.util.Navigator;
import cobraui.util.ThemeFactory;
import cobraui.util.TouchManager;
import cobraui.graphics.BitmapFont;

// Popup Boxes
import cobraui.popup.AlertPopup;
import cobraui.popup.PopupEvent;
import cobraui.popup.MenuPopup;
import cobraui.popup.Popup;
import cobraui.popup.PromptPopup;

import cobraui.graphics.Color;

// UI Elements
import ui.StatusBox;
import ui.Canvas;
import ui.Cursor;
import ui.PaletteBox;
import ui.Toolbox;

// Dialog Boxes
import dialog.BrushPopup;
import dialog.ColorPicker;
import dialog.FilePopup;
import dialog.NewPopup;
import dialog.PreferencesPopup;

// Graphical Helpers
import graphics.BrushFactory;
import graphics.PaletteFactory;

// Tools
import tools.Filler;
import tools.Pencil;
import tools.Picker;
import tools.Move;

// Other Utils
import util.FileManager;

import Preferences;
import Registry;
import ClickManager;

// Libraries
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.System;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.Multitouch;

#if (!flash && !js)
import openfl.events.JoystickEvent;
#end

enum Orientation {
  portrait;
  landscape;
}

class Main extends Sprite {
  private var toolboxWidth:Int;

  private var mainLayout:BorderLayout;
  private var paletteBox:PaletteBox;
  private var statusBox:StatusBox;
  private var toolbox:Toolbox;

  private var brushFactory:BrushFactory;

  private var canvas:Canvas;

  private var cursor:Cursor;

  private var navigator:Navigator;

  private var brushPopup:BrushPopup;
  private var colorPicker:ColorPicker;
  private var filePopup:FilePopup;
  private var menuPopup:MenuPopup;
  private var newPopup:NewPopup;
  private var preferencesPopup:PreferencesPopup;

  private var filler:Filler;
  private var move:Move;
  private var pencil:Pencil;
  private var picker:Picker;

  private var label:Label<String>;
  // FileManager
  private var fileManager:FileManager;

  private var alertPopup:AlertPopup;
  private var promptPopup:PromptPopup;

  private var orientation:Orientation;

  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    Registry.clickManager = new ClickManager(stage);
    Registry.mainWindow = this;

    Registry.fileManager = new FileManager();

    Registry.stage = stage;
    Registry.stageWidth = stage.stageWidth;
    Registry.stageHeight = stage.stageHeight;

    orientation = (stage.stageWidth / stage.stageHeight > 1) ? landscape : portrait;

    Registry.touchManager = new TouchManager();

    Registry.prefs = new Preferences();

    Component.themeFactory = new ThemeFactory("default.theme");


    //
    // Add Events for Stage
    //
    stage.addEventListener(Event.RESIZE, resize);

    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);

#if (!flash && !js)
    //
    // For Android
    stage.addEventListener(JoystickEvent.BUTTON_DOWN, function(e:JoystickEvent) {
      // Menu button
      if (e.id == 16777234) {
        menuPopup.popup();
      } 
      // Back button
      else if (e.id == 27) {
        System.exit(0);
      }
    });

    stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent) {
      if (e.delta > 0) {
        Registry.canvas.changeZoom(2);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      } else {
        Registry.canvas.changeZoom(0.5);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }
    });

    stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, function(e:MouseEvent) {
      Registry.canvas.startDrag();
    });
    stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, function(e:MouseEvent) {
      Registry.canvas.stopDrag();
      Registry.canvas.checkBounds();
      Registry.canvas.setCenter();
    });
#end

    if (Multitouch.supportsTouchEvents) {
      stage.addEventListener(TouchEvent.TOUCH_BEGIN, Registry.touchManager.onTouchBegin);
      stage.addEventListener(TouchEvent.TOUCH_MOVE, Registry.touchManager.onTouchMove);
      stage.addEventListener(TouchEvent.TOUCH_END, Registry.touchManager.onTouchEnd);

      stage.addEventListener(TouchEvent.TOUCH_MOVE, stageTouchMove);
    }

    /*
    addEventListener(DialogEvent.CLOSED, function(e:DialogEvent) {
      trace(">" + e.message + "< just closed");
      //var start = util.Timing.getTime();
      trace(util.Timing.timeFunction(function() {
        var walkFunc:Sprite->String->Void = null;
        walkFunc = function(node:Sprite, ?level:String = "") {
          trace(node.parent);
          for (i in 0...node.numChildren) {
            if (Std.is(node.getChildAt(i), Sprite)) {
              var child:Sprite = cast(node.getChildAt(i), Sprite);
              trace(level + child);
              if (child.numChildren > 0) {
                walkFunc(child, level + "  ");
              }
            }
          }
        };
        walkFunc(this, "");
      }));
      trace(util.Timing.timeFunction(function(){
        trace(util.NodeWalker.findChildrenByClass(this, Component, true));
      }));
      trace(util.Timing.timeFunction(function(){util.NodeWalker.getSiblings(Registry.canvas);}));
      //trace((util.Timing.getTime() - start));
    });
    */

    var halfHeight = Math.floor(stage.stageHeight / 2);
    var halfWidth = Math.floor(stage.stageWidth / 2);
    toolboxWidth = 200;

    brushFactory = new BrushFactory("brushes.png", 7, 4, 0xFF00FF);

    // 
    // Setup Tools
    //
    var revert = function() {
      toolbox.clickButtonByName(Registry.canvas.previousTool.name);
    };
    pencil = new Pencil();
    move = new Move(function() {
      revert();
      Registry.canvas.previousTool = move;
    });
    picker = new Picker(function(color:Int):Void {
      setCanvasBrushColor(color);
      revert();
      Registry.canvas.previousTool = picker;
    });
    filler = new Filler();

    //
    // Setup Canvas
    //
    Registry.canvas = new Canvas(64, 64, brushFactory, pencil);
    if (orientation == landscape) {
      Registry.canvas.zoomRect.width -= toolboxWidth * 2;
      Registry.canvas.zoomRect.x = toolboxWidth;
      Registry.canvas.originalPos = new Point(toolboxWidth, 0);
      Registry.canvas.moveTo(
          Math.floor(toolboxWidth + ((stage.stageWidth - toolboxWidth) / 2) - Registry.canvas.uWidth / 2), 
          Math.floor(stage.stageHeight / 2 - Registry.canvas.uHeight / 2)
      );
    } else {
      Registry.canvas.zoomRect.height -= toolboxWidth * 2;
      Registry.canvas.zoomRect.y = toolboxWidth;
      Registry.canvas.originalPos = new Point(0, toolboxWidth * 2);
      Registry.canvas.moveTo(
          Math.floor(stage.stageWidth / 2 - Registry.canvas.uWidth / 2), 
          Math.floor(toolboxWidth + ((stage.stageHeight - toolboxWidth * 2) / 2) - Registry.canvas.uHeight / 2)
      );
    }

    Registry.clickManager.registerComponent(Registry.canvas, null, true);
    Registry.canvas.addEventListener(ClickEvent.HOLD_CLICK, function(e:ClickEvent) { 
      trace("You've done it! " , e.stageX , e.stageY , e.localX , e.localY);
      //Registry.canvas.changeZoom(2);
      //cursor.changeZoom(Math.floor(Registry.canvas.zoom));
    });

    addChild(Registry.canvas);

    var tempFont = new BitmapFont("profont_2x.png", 16, 8);
    Registry.font = tempFont;
    Label.font = tempFont;
    //Registry.font.drawTextBitmap(Registry.canvas.getCanvas(), 10, 10, "ABCDE");


    //
    // Popup Boxes
    //
    brushPopup = new BrushPopup(0.8, 0.7, brushFactory, function(picked:Int):Void {
      brushFactory.changeBrush(picked);
      cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
    });

    newPopup = new NewPopup(0.7, 0.7);
    filePopup = new FilePopup(0.8, 0.85);
    colorPicker = new ColorPicker(new Color(0xFF0000));
    preferencesPopup = new PreferencesPopup();

    // Menu popup
    menuPopup = new MenuPopup(3, 0);
    var tempButton = new SimpleButton<String>("New");
    tempButton.onClick = function(event:MouseEvent) {
      newPopup.popup();
      menuPopup.hide();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Clear");
    tempButton.onClick = function(event:MouseEvent) {
      Registry.canvas.canvasModified();
      Registry.canvas.clearCanvas();
      menuPopup.hide();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Files");
    tempButton.onClick = function(event:MouseEvent) {
      menuPopup.hide();
      filePopup.popup();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Preferences");
    tempButton.onClick = function(event:MouseEvent) {
      menuPopup.hide();
      preferencesPopup.popup();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Quit");
    tempButton.onClick = function(event:MouseEvent) {
      menuPopup.hide();
      System.exit(0);
    };
    menuPopup.addComponent(tempButton);
    menuPopup.layout.pack();
    


    //
    // Setup Main Layout for handling toolbox and palette box
    //
    mainLayout = new BorderLayout(stage.stageWidth, stage.stageHeight);

    //
    // Setup Palette Box
    //
    paletteBox = new PaletteBox(10, 10, setCanvasBrushColor);

    var paletteFactory = new PaletteFactory();
    paletteFactory.load("colors.dat");

    for (color in paletteFactory.getColors()) {
      paletteBox.addColor(color);
    }
    paletteBox.doneAdding();

    paletteBox.pickColor(brushFactory.mainColor.colorInt);

    addChild(paletteBox);

    mainLayout.assignComponent(paletteBox, BorderLayout.RIGHT, 0.2, 1, percent);

    //
    // Setup Toolbox
    //
    if (orientation == landscape) {
      toolbox = new Toolbox(10, 10, 2, 6);
    } else {
      toolbox = new Toolbox(10, 10, 6, 2);
    }

    toolbox.setTilesheet("toolbox.png", 4, 4, 0xFF00FF);
    var buttons:Array<Dynamic> = [
      ['popup', function(button):Void {
        brushPopup.popup();
      }, 9,                 null, null],
      ['pencil', function(button):Void { 
        Registry.canvas.currentTool = pencil; 
      }, pencil.imageIndex, 1,    true],
      ['move', function(button):Void { 
        //move.revert = button.state == Button.CLICKED;
        Registry.canvas.previousTool = Registry.canvas.currentTool;
        Registry.canvas.currentTool = move; 
      }, move.imageIndex,   1,    null],
      ['picker', function(button):Void { 
        Registry.canvas.previousTool = Registry.canvas.currentTool;
        Registry.canvas.currentTool = picker; 
      }, picker.imageIndex, 1,    null],
      ['filler', function(button):Void {
        Registry.canvas.currentTool = filler;
      }, filler.imageIndex, 1,    null],
      ['undo', function(button):Void {
        Registry.canvas.undoStep();
      }, 10,                null, null],
      ['redo', function(button):Void {
        Registry.canvas.redoStep();
      }, 11,                null, null],
      ['zoomin', function(button):Void {
        Registry.canvas.changeZoom(2);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }, 6,                 null, null],
      ['zoomout', function(button):Void {
        Registry.canvas.changeZoom(0.5);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }, 7,                 null, null],
      ['quickview', function(button) {
        Registry.canvas.quickView();
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }, 12,                 null, null],
      ['paldown', function(button) {
        menuPopup.popup();
      }, 4,                 null, null]
    ];

    statusBox = new StatusBox();

    statusBox.onClick = function(event:MouseEvent) {
      setCanvasBrushColor();
    };

    toolbox.addButtonLike(statusBox);

    for (button in buttons) {
      toolbox.addButton(button[0], button[1], button[2], button[3], button[4]);
    }
    toolbox.doneAdding();

    addChild(toolbox);
    mainLayout.assignComponent(toolbox, BorderLayout.LEFT, 0.2, 1, percent);

    mainLayout.pack();

    // Put Popup Boxes on Top
    addChild(brushPopup);
    addChild(filePopup);
    addChild(newPopup);
    addChild(menuPopup);
    addChild(colorPicker);
    addChild(preferencesPopup);

    /*
    alertPopup = new AlertPopup("You cool bro?", confirm);
    addChild(alertPopup);

    addEventListener(DialogEvent.MESSAGE, function(e:DialogEvent) {
      trace("Alert just closed: message: " + e.message + ", id: " + e.id);
    });
    */

    /*
    promptPopup = new PromptPopup("test");
    promptPopup.addAllowed(~/[A-Za-z._-]/);
    addChild(promptPopup);
    */

    //navigator = new Navigator(toolbox.getChildAt(0));
    //addChild(navigator);

    //
    // Setup Cursor
    //
    Registry.cursor = new Cursor();
    cursor = Registry.cursor;
    cursor.addTypeCursor("canvas", brushFactory.getBrushImage(), true);
    cursor.visible = false;
    addChild(cursor);

    //trace(Capabilities.screenDPI);

    //toolbox.clickButton(6);

    Registry.canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
    Registry.canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);

    resizeComponents(true);

    //trace("Moving to center");
    Registry.canvas.centerCanvas();

  }

  private function touchTouchBegin(event:MouseEvent) {
  }

  private function canvasMouseOver(event:MouseEvent) {
    cursor.setCursor("canvas");
    cursor.visible = true;
  }

  private function canvasMouseOut(event:MouseEvent) {
    cursor.setCursor("default");
    cursor.visible = false;
  }

  private function setCanvasBrushColor(?color:Int, ?fromPaletteBox:Bool = false):Void {
    if (color == null) {
      brushFactory.swapColors();
    } else {
      brushFactory.changeColor(color);
    }
    cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
    statusBox.forceRedraw();
    if (!fromPaletteBox) {
      paletteBox.pickColor(brushFactory.mainColor.colorInt);
    }
  }

  private function resizeComponents(?initial:Bool = false):Orientation {
    var ratio = (stage.stageWidth / stage.stageHeight);
    mainLayout.resize(stage.stageWidth, stage.stageHeight);
    if (ratio > 1) {
      mainLayout.updateComponent(toolbox, BorderLayout.LEFT, 0.2, 1, percent);
      mainLayout.updateComponent(paletteBox, BorderLayout.RIGHT, 0.2, 1, percent);
      toolbox.resizeGrid(2, 6);
      paletteBox.resizeGrid(Registry.prefs.paletteX, Registry.prefs.paletteY);
      return landscape;
    } 

    mainLayout.updateComponent(toolbox, BorderLayout.TOP, 1, 0.2, percent);
    mainLayout.updateComponent(paletteBox, BorderLayout.BOTTOM, 1, 0.2, percent);
    toolbox.resizeGrid(6, 2);
    paletteBox.resizeGrid(Registry.prefs.paletteY, Registry.prefs.paletteX);
    return portrait;
  }


  // -------------------------------------------------- 
  //                  Event Handlers
  // -------------------------------------------------- 

  private function addedToStage(event:Event):Void {
    construct();
  }

  private function resize(event:Event):Void {
    var newOrientation = resizeComponents();
    if (newOrientation == landscape) {
      Registry.canvas.zoomRect.x = toolbox.uWidth;
      Registry.canvas.zoomRect.y = 0;
      Registry.canvas.zoomRect.width = stage.stageWidth - toolbox.uWidth * 2;
      Registry.canvas.zoomRect.height = stage.stageHeight;
      Registry.canvas.originalPos.x = toolbox.uWidth;
      Registry.canvas.originalPos.y = 0;
    } else {
      Registry.canvas.zoomRect.x = 0;
      Registry.canvas.zoomRect.y = toolbox.uHeight;
      Registry.canvas.zoomRect.width = stage.stageWidth;
      Registry.canvas.zoomRect.height = stage.stageHeight - toolbox.uHeight * 2;
      Registry.canvas.originalPos.x = 0;
      Registry.canvas.originalPos.y = toolbox.uHeight;
    }
    if (newOrientation != orientation) {
      orientation = newOrientation;
      //trace("changed orientation: ", orientation);
      var temp = Registry.canvas.centerPos.x;
      Registry.canvas.centerPos.x = Registry.canvas.centerPos.y;
      Registry.canvas.centerPos.y = temp;
      Registry.canvas.centerishCanvas();
    } else {
    //trace("orientation: ", orientation);
    //Registry.canvas.centerCanvas(false);
      Registry.canvas.centerishCanvas();
    }
  }

  //
  // Mouse Events
  //
  private function stageMouseMove(event:MouseEvent):Void {
    cursor.update(event.stageX, event.stageY);
  }

  private function stageMouseUp(event:MouseEvent):Void {
  }
  
  private function stageMouseDown(event:MouseEvent):Void {
    if (event.target == event.currentTarget || event.target == Registry.canvas) {
    }
  }

  //
  // Touch Events
  //
  private function stageTouchBegin(event:TouchEvent):Void {
  }

  private function stageTouchMove(event:TouchEvent):Void {
    if (Registry.touchManager.touchCount == 2) {
      Registry.canvas.changeZoom((Registry.touchManager.newScale - 1) / Math.sqrt(Registry.canvas.zoom) + 1);
      cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      Registry.canvas.moveBy(Registry.touchManager.translateX, Registry.touchManager.translateY);
    }
  }

  private function stageTouchEnd(event:TouchEvent):Void {
  }

  private function stageKeyDown(event:KeyboardEvent):Void {
    var keyCode = event.keyCode;
#if (cpp || neko)
    if (event.keyCode >= 97 && event.keyCode <= 123) {
      keyCode -= 32;
    }
#end
    switch(keyCode) {
      case Keyboard.ESCAPE, Keyboard.Q:
        System.exit(0);
      case Keyboard.LEFT:
        Registry.canvas.x += 10 * Registry.canvas.zoom;
      case Keyboard.RIGHT:
        Registry.canvas.x -= 10 * Registry.canvas.zoom;
      case Keyboard.UP:
        Registry.canvas.y += 10 * Registry.canvas.zoom;
      case Keyboard.DOWN:
        Registry.canvas.y -= 10 * Registry.canvas.zoom;
#if !js
      case Keyboard.EQUAL:
        toolbox.clickButtonByName("zoomin");
      case Keyboard.MINUS:
        toolbox.clickButtonByName("zoomout");
#end
      case Keyboard.ENTER:
        menuPopup.popup();
      case Keyboard.P:
        preferencesPopup.popup();
      /*
      case Keyboard.D:
        toolbox.resize(toolbox.uWidth + 20, toolbox.uHeight);
        paletteBox.resize(paletteBox.uWidth + 20, paletteBox.uHeight);
      case Keyboard.A:
        toolbox.resize(toolbox.uWidth - 20, toolbox.uHeight);
        paletteBox.resize(paletteBox.uWidth - 20, paletteBox.uHeight);
      case Keyboard.V:
        Registry.canvas.quickView();
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      case Keyboard.X:
        setCanvasBrushColor();
      case Keyboard.N:
        //navigator.nextNode();
      //case Keyboard.P:
        //navigator.previousNode();
      case Keyboard.G:
        //navigator.clickNode();
      case Keyboard.P:
        colorPicker.popup();
      case Keyboard.U:
        Registry.canvas.undoStep();
      */
    }
  }
}

