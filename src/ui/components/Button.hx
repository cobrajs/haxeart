package ui.components;

import com.eclecticdesignstudio.motion.Actuate;

import nme.display.GradientType;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.Graphics;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.text.TextFormat;
import nme.text.TextField;
import nme.Assets;

class Button extends Sprite {
  public static var HOVERING:Int = 0;
  public static var NORMAL:Int = 1;
  public static var CLICKED:Int = 2;

  // Size and style
  private var uWidth:Int;
  private var uHeight:Int;
  private var bevel:Int;
  private var origX:Float;
  private var origY:Float;

  // Button state vars
  public var state:Int;
  private var oldState:Int;
  private var constructed:Bool;
  private var stayPressed:Bool;
  private var clickHandled:Bool;

  // Button state images
  private var hover:Sprite;
  private var clicked:Sprite;
  private var normal:Sprite;

  // Button Text
  private var buttonText:String;
  private var buttonTextField:TextField;

  // Button Image
  private var buttonImage:Bitmap;
  private var buttonOverlay:Sprite;

  // Button actions
  public var clickAction:Button->Void;

  public function new(width:Int, height:Int, ?bevel:Int = 8, ?stayPressed:Bool = false) {
    super();

    constructed = false;

    uWidth = width;
    uHeight = height;

    this.stayPressed = stayPressed;
    this.clickHandled = false;

    if (bevel < 0) {
      throw "Bevel must be greater than 0";
    }
    this.bevel = bevel;

    hover = new Sprite();
    addChild(hover);
    drawButton(hover, HOVERING);

    normal = new Sprite();
    addChild(normal);
    drawButton(normal, NORMAL);

    clicked = new Sprite();
    addChild(clicked);
    drawButton(clicked, CLICKED);

    oldState = -1;
    changeState(NORMAL);

		var font = Assets.getFont ("assets/VeraSe.ttf");
		var format = new TextFormat (font.fontName, 12, 0x000000);
		
		buttonTextField = new TextField ();
		buttonTextField.defaultTextFormat = format;
		buttonTextField.selectable = false;
		buttonTextField.embedFonts = true;
		//buttonTextField.width = 160;
		//buttonTextField.height = 40;
		buttonTextField.x = 20;
		buttonTextField.y = 20;
    buttonTextField.visible = false;

		addChild (buttonTextField);

    addEventListener(Event.ADDED_TO_STAGE, addedToStage);
  }

  public function setImage(location:String) {
    try {
      buttonImage = new Bitmap(Assets.getBitmapData("assets/" + location));
      buttonImage.x = uWidth / 2 - buttonImage.width / 2;
      buttonImage.y = uHeight / 2 - buttonImage.height / 2;

      addChild(buttonImage);
    }
    catch(e:Dynamic) {
    }
  }

  public function drawImage(width:Int, height:Int):Graphics {
    if (buttonOverlay == null) {
      buttonOverlay = new Sprite();

      addChild(buttonOverlay);
    }

    buttonOverlay.x = uWidth / 2 - width / 2;
    buttonOverlay.y = uHeight / 2 - height / 2;

    return buttonOverlay.graphics;
  }

  public function setText(string:String) {
    buttonText = string;
		buttonTextField.text = string;
    buttonTextField.x = uWidth / 2 - buttonTextField.textWidth / 2;
    buttonTextField.y = uHeight / 2 - buttonTextField.textHeight / 2 - 2;
    buttonTextField.visible = true;
  }

  private function construct() {
    //addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    //addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    origX = x;
    origY = y;
    addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
    addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
  }

  private function drawButton(canvas:Sprite, state:Int) {
    var colors = [
      // Hovering
      { dark : 0x999999, light : 0xBBBBBB, front : 0xDDDDDD },
      // Normal
      { dark : 0xBBBBBB, light : 0xDDDDDD, front : 0xEEEEEE },
      // Clicked
      { dark : 0x888888, light : 0x555555, front : 0xAAAAAA }
    ];
    var offset = bevel;
    var gfx = canvas.graphics;
    //gfx.beginGradientFill(GradientType.LINEAR, [0x444444, 0xEEEEEE], [1, 1], [0x00, 0xFF]);
    //gfx.drawRect(0, 0, uWidth, uHeight);
    //gfx.endFill();
    gfx.lineStyle(1, 0x000000);
    gfx.beginFill(offset == 0 ? colors[state].light : colors[state].light);
    gfx.drawRect(0, 0, uWidth, uHeight);
    gfx.endFill();

    if (offset > 0) {
      gfx.beginFill(colors[state].dark);
      gfx.moveTo(uWidth, 0);
      gfx.lineTo(uWidth - offset, offset);
      gfx.lineTo(offset, uHeight - offset);
      gfx.lineTo(0, uHeight);
      gfx.lineTo(uWidth, uHeight);
      gfx.lineTo(uWidth, 0);
      gfx.endFill();

      gfx.moveTo(0, 0);
      gfx.lineTo(offset, offset);
      gfx.lineTo(uWidth - offset, uHeight - offset);
      gfx.lineTo(uWidth, uHeight);

      gfx.beginFill(colors[state].front);
      gfx.drawRect(offset, offset, uWidth - offset * 2, uHeight - offset * 2);
      gfx.endFill();
    }

    gfx.lineStyle();
  }

  public function changeState(?newState:Int) {
    if (newState == null) {
      newState = oldState;
    }

    switch (newState) {
      case HOVERING: 
        this.clicked.visible = false;
        this.normal.visible = false;
        this.hover.visible = true;
      case NORMAL:
        this.clicked.visible = false;
        this.normal.visible = true;
        this.hover.visible = false;
      case CLICKED:
        this.clicked.visible = true;
        this.normal.visible = false;
        this.hover.visible = false;
    }
    oldState = state == -1 ? newState : state;
    state = newState;
  }

  //
  // ---------- Event Handlers ----------
  //

  private function addedToStage(event:Event):Void {
    if (!constructed) {
      construct();
      constructed = true;
    }
  }

  private function mouseDown(event:MouseEvent):Void {
    changeState(CLICKED);
    /*
    var scale = 0.9;
    Actuate.tween(this, 0.4, {
      x: this.x + (this.uWidth - this.uWidth * scale) / 2, 
      y: this.y + (this.uHeight - this.uHeight * scale) / 2,
      scaleX: scale,
      scaleY: scale
    }, true);
    */
  }

  private function mouseUp(event:MouseEvent):Void {
    if (clickAction != null) {
      clickAction(this);
      this.clickHandled = true;
    }
    if (!stayPressed) {
      changeState();
    }
    /*
    Actuate.tween(this, 0.4, {
      x: origX, 
      y: origY,
      scaleX: 1,
      scaleY: 1
    }, true);
    */
    event.stopPropagation();
  }

  private function stageMouseUp(event:MouseEvent):Void {
    if (state == CLICKED) {
      if (clickAction != null && !this.clickHandled) {
        clickAction(this);
      }
      if (!stayPressed) {
        changeState(NORMAL);
      }
      /*
      Actuate.tween(this, 0.4, {
        x: origX, 
        y: origY,
        scaleX: 1,
        scaleY: 1
      }, true);
      */
    }
    this.clickHandled = false;
  }
}
