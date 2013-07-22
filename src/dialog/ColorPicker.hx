package dialog;

import cobraui.graphics.Color;

import cobraui.popup.Popup;
import cobraui.popup.PopupEvent;
import cobraui.popup.PromptPopup;

import cobraui.components.Label;
import cobraui.components.SimpleButton;
import cobraui.components.Container;
import cobraui.components.Slider;

import cobraui.layouts.GridLayout;
import cobraui.layouts.BorderLayout;

import flash.events.Event;
import flash.events.MouseEvent;

class ColorPicker extends Popup {
  public static var TYPE:String = "colorpicker";

  public var currentColor:Color;

  private var redSlider:Slider;
  private var greenSlider:Slider;
  private var blueSlider:Slider;
  private var label:Label<String>;
  private var buttons:Container;

  public function new(?color:Color) {
    super(0.7, 0.7, "Color Picker", BorderLayout.MIDDLE, false);

    currentColor = color == null ? new Color("white") : color;

    var sliderMin = 0;
    var sliderMax = 255;

    layout = new GridLayout(uWidth, uHeight, 1, 0);

    // Setup color display
    label = new Label<String>("");
    window.addChild(label);
    layout.addComponent(label);

    // Setup color sliders
    redSlider = new Slider(sliderMin, sliderMax, color.r, 1);
    redSlider.addEventListener(Event.CHANGE, updateColor);
    window.addChild(redSlider);
    layout.addComponent(redSlider);

    greenSlider = new Slider(sliderMin, sliderMax, color.g, 1);
    greenSlider.addEventListener(Event.CHANGE, updateColor);
    window.addChild(greenSlider);
    layout.addComponent(greenSlider);
    
    blueSlider = new Slider(sliderMin, sliderMax, color.b, 1);
    blueSlider.addEventListener(Event.CHANGE, updateColor);
    window.addChild(blueSlider);
    layout.addComponent(blueSlider);

    // Setup buttons
    buttons = new Container();
    buttons.layout = new GridLayout(10, 10, 0, 1);
    var tempButton:SimpleButton<String> = null;
    var messageAndClose = function(useColor:Bool) {
      dispatchEvent(new PopupEvent(PopupEvent.MESSAGE, useColor ? Std.string(currentColor.colorInt) : "", this.id));
      dispatchEvent(new PopupEvent(PopupEvent.CLOSED, TYPE, this.id));
      this.hide();
    };
    tempButton = new SimpleButton<String>("Enter Hex");
    tempButton.onClick = function(event:MouseEvent) {
      var tempPopup = new PromptPopup(currentColor.toHexString());
      tempPopup.addAllowed(~/[A-Za-z0-9]/);
      addChild(tempPopup);
      tempPopup.popup();
      var id = tempPopup.id;
      var msgFnc:PopupEvent->Void = null;
      msgFnc = function(e:PopupEvent) {
        if (e.id == id) {
          if (e.message != "" && e.message != null) {
            currentColor.update(e.message);
            tempPopup.hide();
            removeEventListener(PopupEvent.MESSAGE, msgFnc);
            removeChild(tempPopup);
            updateSliders();
          }
        }
      };

      addEventListener(PopupEvent.MESSAGE, msgFnc);
    };
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    tempButton = new SimpleButton<String>("Use Color");
    tempButton.onClick = function(event:MouseEvent) {
      messageAndClose(true);
    };
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    tempButton = new SimpleButton<String>("Cancel");
    tempButton.onClick = function(event:MouseEvent) {
      messageAndClose(false);
    };
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    window.addChild(buttons);
    buttons.layout.pack();
    layout.addComponent(buttons);

    layout.pack();

    updateColor();
  }

  private function updateSliders() {
    redSlider.setValue(currentColor.r);
    greenSlider.setValue(currentColor.g);
    blueSlider.setValue(currentColor.b);
    updateLabel();
  }

  private function updateColor(?e:Event) {
    currentColor.r = redSlider.getValue();
    currentColor.g = greenSlider.getValue();
    currentColor.b = blueSlider.getValue();
    updateLabel();
  }

  private function updateLabel() {
    label.background = currentColor;
    label.redraw();
  }

}
