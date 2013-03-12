package dialog;

import graphics.Color;

import dialog.Popup;
import dialog.DialogEvent;

import ui.components.Label;
import ui.components.SimpleButton;
import ui.components.Container;
import ui.components.Slider;

import ui.layouts.GridLayout;
import ui.layouts.BorderLayout;

import nme.events.Event;
import nme.events.MouseEvent;

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
      dispatchEvent(new DialogEvent(DialogEvent.MESSAGE, useColor ? Std.string(currentColor.colorInt) : "", this.id));
      dispatchEvent(new DialogEvent(DialogEvent.CLOSED, TYPE, this.id));
      this.hide();
    };
    tempButton = new SimpleButton<String>("Use Color");
    tempButton.borderWidth = 1;
    tempButton.onClick = function(event:MouseEvent) {
      messageAndClose(true);
    }
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    tempButton = new SimpleButton<String>("Cancel");
    tempButton.borderWidth = 1;
    tempButton.onClick = function(event:MouseEvent) {
      messageAndClose(false);
    }
    buttons.addChild(tempButton);
    buttons.layout.addComponent(tempButton);
    window.addChild(buttons);
    buttons.layout.pack();
    layout.addComponent(buttons);

    layout.pack();

    updateColor();
  }

  private function updateColor(?e:Event) {
    currentColor.r = redSlider.value;
    currentColor.g = greenSlider.value;
    currentColor.b = blueSlider.value;
    label.background = currentColor;
    label.redraw();
  }

}
