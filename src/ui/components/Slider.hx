package ui.components;

import graphics.Color;
import ui.components.Container;
import ui.components.SimpleButton;
import ui.components.Label;
import ui.layouts.BorderLayout;

import nme.events.MouseEvent;
import nme.geom.Rectangle;

class Slider extends Container {
  public var value(default, setValue):Int;

  public var minimum:Int;
  public var maximum:Int;
  public var step:Int;

  private var slider:Component;
  private var dragging:Bool;
  private var sliderBackground:Component;

  private var valueLabel:Label<String>;

  public function new(minimum:Int, maximum:Int, ?defaultValue:Int, ?step:Int = 1) {
    super();

    layout = new BorderLayout(10, 10);

    sliderBackground = new Component();
    sliderBackground.borderWidth = 2;
    sliderBackground.background = new Color(0xCCCCCC);
    addChild(sliderBackground);
    layout.assignComponent(sliderBackground, BorderLayout.RIGHT, 0.7, 1, percent);

    slider = new Component();
    slider.borderWidth = 2;
    sliderBackground.addChild(slider);
    layout.assignComponent(slider, BorderLayout.CUSTOM, 0.2, 1, percent, function() {
      slider.x = (value / (maximum - minimum)) * (sliderBackground.uWidth - slider.uWidth);
    });

    dragging = false;

    slider.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
      slider.startDrag(false, new Rectangle(0, 0, sliderBackground.uWidth - slider.uWidth, 0));
      dragging = true;
    });

    slider.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
      if (dragging) {
        value = Std.int((slider.x / (sliderBackground.uWidth - slider.uWidth)) * (maximum - minimum) + minimum);
      }
    });

    var stopDragging = function(e:MouseEvent) {
      slider.stopDrag();
      dragging = false;
    };

    slider.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
    slider.addEventListener(MouseEvent.MOUSE_OUT, stopDragging);

    valueLabel = new Label<String>("");
    valueLabel.background = new Color(0xAAAAAA);
    valueLabel.hAlign = center;
    valueLabel.borderWidth = 2;
    addChild(valueLabel);
    layout.assignComponent(valueLabel, BorderLayout.LEFT, 0.3, 1, percent);

    value = defaultValue == null ? Std.int((maximum - minimum) / step / 2) * step : defaultValue;

    layout.pack();
  }

  public function setValue(value:Int):Int {
    this.value = value;
    valueLabel.content = Std.string(value);
    return value;
  }
}
