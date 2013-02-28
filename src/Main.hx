package ;

// TODO: Fill in README.md

// UI Elements
import ui.components.Component;
import ui.components.Button;
import ui.components.Label;
import ui.components.Selector;
import ui.components.SimpleButton;
import ui.components.TextInput;
import ui.BitmapFont;
import ui.Canvas;
import ui.Cursor;
import ui.PaletteBox;
import ui.Toolbox;
import ui.TouchManager;

// Dialog Boxes
import dialog.AlertPopup;
import dialog.BrushPopup;
import dialog.DialogEvent;
import dialog.FilePopup;
import dialog.MenuPopup;
import dialog.NewPopup;
import dialog.PromptPopup;
import dialog.Popup;

// Graphical Helpers
import graphics.BrushFactory;
import graphics.PaletteFactory;
import graphics.Color;

// Tools
import tools.Filler;
import tools.Pencil;
import tools.Picker;
import tools.Move;

// Iterators
import util.LineIter;

// Other Utils
import util.Utils;
import util.FileManager;

import Preferences;
import Registry;

// Libraries
import nme.display.Graphics;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.system.System;
import nme.ui.Keyboard;
import nme.ui.Mouse;
import nme.ui.Multitouch;

import nme.filesystem.File;

class Main extends Sprite {

  private var buttons:Array<Button>;
  private var toolbox:Toolbox;
  private var paletteBox:PaletteBox;

  private var brushFactory:BrushFactory;

  private var canvas:Canvas;

  private var cursor:Cursor;

  private var brushPopup:BrushPopup;
  private var filePopup:FilePopup;
  private var menuPopup:MenuPopup;
  private var newPopup:NewPopup;

  private var pencil:Pencil;
  private var move:Move;
  private var picker:Picker;
  private var filler:Filler;

  private var label:Label<String>;
  // FileManager
  private var fileManager:FileManager;

  private var alertPopup:AlertPopup;
  private var promptPopup:PromptPopup;

  public function new() {
    super();

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  private function construct():Void {
    Registry.fileManager = new FileManager();

    Registry.stage = stage;
    Registry.stageWidth = stage.stageWidth;
    Registry.stageHeight = stage.stageHeight;

    Registry.touchManager = new TouchManager();

    Registry.prefs = new Preferences();

    //
    // Add Events for Stage
    //
    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDown);

    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);

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
    });

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
    var toolboxWidth = 200;

    brushFactory = new BrushFactory("brushes.png", 7, 7, 0xFF00FF);

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
    Registry.canvas.zoomRect.width = stage.stageWidth - 200;
    Registry.canvas.zoomRect.x = 200;
    Registry.canvas.originalPos = new Point(toolboxWidth, 0);
    Registry.canvas.moveTo(
        Math.floor(200 + ((stage.stageWidth - 200) / 2) - Registry.canvas.uWidth / 2), 
        Math.floor(stage.stageHeight / 2 - Registry.canvas.uHeight / 2)
    );

    addChild(Registry.canvas);

    Registry.font = new BitmapFont("profont_2x.png", 16, 8);
    //Registry.font.drawTextBitmap(Registry.canvas.getCanvas(), 10, 10, "ABCDE");


    //
    // Setup Palette Box
    //
    paletteBox = new PaletteBox(toolboxWidth, halfHeight - 50, 3, 3, setCanvasBrushColor);
    paletteBox.x = 0;
    paletteBox.y = halfHeight + 50;

    var paletteFactory = new PaletteFactory();
    paletteFactory.load("colors.dat");

    for (color in paletteFactory.getColors()) {
      paletteBox.addColor(color);
    }
    paletteBox.doneAdding();

    addChild(paletteBox);


    //
    // Popup Boxes
    //
    brushPopup = new BrushPopup(0.6, 0.5, brushFactory, function(picked:Int):Void {
      brushFactory.changeBrush(picked);
      cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
    });

    newPopup = new NewPopup(0.7, 0.7);
    filePopup = new FilePopup(0.8, 0.85);

    menuPopup = new MenuPopup();
    var tempButton = new SimpleButton<String>("New");
    tempButton.borderWidth = 2;
    tempButton.onClick = function(event:MouseEvent) {
      newPopup.popup();
      menuPopup.hide();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Clear");
    tempButton.borderWidth = 2;
    tempButton.onClick = function(event:MouseEvent) {
      Registry.canvas.canvasModified();
      Registry.canvas.clearCanvas();
      menuPopup.hide();
    };
    menuPopup.addComponent(tempButton);

    tempButton = new SimpleButton<String>("Files");
    tempButton.borderWidth = 2;
    tempButton.onClick = function(event:MouseEvent) {
      menuPopup.hide();
      filePopup.popup();
    };
    menuPopup.addComponent(tempButton);
    menuPopup.layout.pack();

    //
    // Setup Toolbox
    //
    toolbox = new Toolbox(toolboxWidth, halfHeight + 50,   3, 4,   5);
    toolbox.x = 0;
    toolbox.y = 0;

    toolbox.setTilesheet("toolbox.png", 4, 4, 0xFF00FF);
    var buttons = [
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
      ['popup', function(button):Void {
        brushPopup.popup();
      }, 9,                 null, null],
      ['zoomin', function(button):Void {
        Registry.canvas.changeZoom(2);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }, 6,                 null, null],
      ['zoomout', function(button):Void {
        Registry.canvas.changeZoom(0.5);
        cursor.changeZoom(Math.floor(Registry.canvas.zoom));
      }, 7,                 null, null],

      // The next two are pretty much just for testing stuff right now

      ['palup', function(button) {
        Registry.canvas.quickView();
      }, 4,                 null, null],
      ['paldown', function(button) {
        menuPopup.popup();
      }, 4,                 null, null]
    ];

    for (button in buttons) {
      toolbox.addButton(button[0], button[1], button[2], button[3], button[4]);
    }
    toolbox.doneAdding();

    addChild(toolbox);

    // Put Popup Box on Top
    addChild(brushPopup);
    addChild(filePopup);
    addChild(newPopup);
    addChild(menuPopup);

    /*
    alertPopup = new AlertPopup("You cool bro?", confirm);
    addChild(alertPopup);

    addEventListener(DialogEvent.MESSAGE, function(e:DialogEvent) {
      trace("Alert just closed: message: " + e.message + ", id: " + e.id);
    });
    */

    promptPopup = new PromptPopup("test");
    promptPopup.addAllowed(~/[A-Za-z._-]/);
    addChild(promptPopup);

    //
    // Setup Cursor
    //
    cursor = new Cursor();
    cursor.addTypeCursor("canvas", brushFactory.getBrushImage(), true);
    cursor.visible = false;
    addChild(cursor);

    //toolbox.clickButton(6);

    Registry.canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
    Registry.canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);

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

  private function setCanvasBrushColor(color:Int):Void {
    brushFactory.changeColor(color);
    cursor.updateTypeCursor("canvas", brushFactory.getBrushImage());
  }
  
  private function drawLine():Void {
    for (p in (new LineIter(10, 10, 100, 80))) {
      Registry.canvas.drawDot(p[0], p[1]);
    }
  }

  private function paletteBoxScrollUp():Void {
  }

  private function drawRedCircle():Void { drawCircle(0xFF0000); }
  private function drawGreenCircle():Void { drawCircle(0x00FF00); }
  private function drawBlueCircle():Void { drawCircle(0x0000FF); }
  private function drawCircle(color:Int):Void {
    var gfx = this.graphics;
    var tempX = Math.random() * stage.stageWidth;
    var tempY = Math.random() * (stage.stageHeight - 64);
    gfx.beginFill(color);
    gfx.drawCircle(tempX, tempY, 30);
    gfx.endFill();
  }


  // -------------------------------------------------- 
  //                  Event Handlers
  // -------------------------------------------------- 

  private function addedToStage(event:Event):Void {
    construct();
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
      case Keyboard.ESCAPE:
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
      case Keyboard.SPACE:
        //alertPopup.popup();
        promptPopup.popup();
      case Keyboard.D:
        toolbox.resize(toolbox.uWidth + 20, toolbox.uHeight);
        paletteBox.resize(paletteBox.uWidth + 20, paletteBox.uHeight);
      case Keyboard.A:
        toolbox.resize(toolbox.uWidth - 20, toolbox.uHeight);
        paletteBox.resize(paletteBox.uWidth - 20, paletteBox.uHeight);
    }
  }
}

