package dialog;

import com.eclecticdesignstudio.motion.Actuate;

import ui.layouts.BorderLayout;
import ui.components.Component;
import ui.components.Label;
import graphics.Color;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.Assets;
import nme.events.MouseEvent;
import nme.events.Event;

class Popup extends Sprite {

  // In percent of screen
  private var pWidth:Float;
  private var pHeight:Float;
  
  // Calculated from percent
  private var uWidth:Float;
  private var uHeight:Float;

  private var window:Component;
  private var closeButton:Sprite;
  private var titleBar:Label<String>;
  private var overlay:Sprite;

  private var popupLayout:BorderLayout;

  public var id:Int;

  public function new(width:Float, height:Float, titleLabel:String, ?position:Int = -1, ?closeButton:Bool = true) {
    super();

    pWidth = width;
    pHeight = height;

    uWidth = Registry.stageWidth * pWidth;
    uHeight = Registry.stageHeight * pHeight;

    overlay = new Sprite();
    var gfx = overlay.graphics;
    gfx.beginFill(0x555555, 0.5);
    gfx.drawRect(0, 0, Registry.stageWidth, Registry.stageHeight);
    gfx.endFill();
    addChild(overlay);

    window = new Component();
    window.borderWidth = 2;
    addChild(window);

    this.visible = false;

    if (closeButton) {
      this.closeButton = new Sprite();
      var tempBitmap = new Bitmap(Assets.getBitmapData("assets/close_button.png"));
      this.closeButton.addChild(tempBitmap);
      window.addChild(this.closeButton);
    }

    if (titleLabel != "" && titleLabel != null) {
      titleBar = new Label<String>(titleLabel);
      titleBar.borderWidth = 2;
      titleBar.background = new Color(0xAAAAAA);
      titleBar.hAlign = center;
      titleBar.resize(uWidth, 25);
      titleBar.y = -25;
      window.addChild(titleBar);
    }

    popupLayout = new BorderLayout(Registry.stageWidth, Registry.stageHeight);
    popupLayout.assignComponent(window, position == -1 ? BorderLayout.MIDDLE : position, width, height, percent);

    addEventListener(Event.ADDED, function(e:Event) {
      popupLayout.pack();
      if (this.closeButton != null) {
        this.closeButton.x = window.width;
      }
    });

    id = Registry.getNextId();
    trace(id);

    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
  }

  //public function popup(?x:Int, ?y:Int) {
  public function popup() {
    // Forget the juiciness stuff for now :P
    /*
    window.x = 0;
    window.y = 0;
    window.scaleX = 0.5;
    window.scaleY = 0.5;
    window.alpha = 0;
    this.visible = true;
    Actuate.tween(window, 0.5, {
      x      : popupX,
      y      : popupY,
      scaleX : 1,
      scaleY : 1,
      alpha  : 1
    }, true);
    */
    this.visible = true;
  }

  public function hide():Void {
    /*
    var scale = 1.5;
    Actuate.tween(window, 0.3, {
      x      : x - ((window.width * scale) - window.width) / 2,
      y      : y - ((window.height * scale) - window.height) / 2,
      scaleX : scale,
      scaleY : scale,
      alpha  : 0
    }, true).onComplete(function():Void {
      this.visible = false;
    });
    */
    this.visible = false;
  }

  private function onMouseUp(event:MouseEvent) {
    if (event.target == closeButton) {
      this.visible = false;
    }
  }
}
