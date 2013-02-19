package ui.components;

import graphics.Color;
import ui.components.Container;
import ui.components.SimpleButton;
import ui.components.Label;
import ui.layouts.GridLayout;

import nme.events.MouseEvent;


class Slider extends Container {
  public var value(default, setValue):Int;

  private var valueLabel:Label<String>;

  public function new(?defaultValue:Int = 32) {
    super();

    layout = new GridLayout(10, 10, 0, 1);

    var incrButton = new SimpleButton<String>("+");
    incrButton.borderWidth = 2;
    incrButton.onClick = function(event:MouseEvent) {
      value *= 2;
    };
    addChild(incrButton);
    layout.addComponent(incrButton);

    var decButton = new SimpleButton<String>("-");
    decButton.borderWidth = 2;
    decButton.onClick = function(event:MouseEvent) {
      value = Std.int(value / 2);
    };
    addChild(decButton);
    layout.addComponent(decButton);

    valueLabel = new Label<String>(Std.string(value));
    valueLabel.background = new Color(0xAAAAAA);
    valueLabel.hAlign = center;
    valueLabel.borderWidth = 2;
    addChild(valueLabel);
    layout.addComponent(valueLabel);

    layout.pack();

    value = defaultValue;
  }

  public function setValue(value:Int):Int {
    this.value = value;
    valueLabel.content = Std.string(value);
    return value;
  }
}
