package ui.components;

import ui.components.Label;

import nme.events.MouseEvent;

class Selector extends Label {
  public var options(default, setOptions):Array<String>;
  public var selected(getSelected, setSelected):String;
  public var selectedIndex(default, setSelectedIndex):Int;

  public function new(options:Array<String>, ?defaultOption:Int = 0) {
    super(options[defaultOption], 0);

    this.options = options;
    this.selectedIndex = defaultOption;

    addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
  }

  private function mouseDown(event:MouseEvent) {
    selectedIndex++;
  }

  private function setOptions(o:Array<String>):Array<String> {
    options = o;
    selectedIndex = 0;
    return options;
  }

  private function getSelected():String {
    return options[selectedIndex];
  }

  private function setSelected(s:String):String {
    for (i in 0...options.length) {
      if (options[i] == s) {
        selectedIndex = i;
        break;
      }
    }
    return s;
  }

  private function setSelectedIndex(i:Int):Int {
    selectedIndex = i;
    if (selectedIndex >= options.length) {
      selectedIndex = 0;
      return selectedIndex;
    }

    text = options[selectedIndex];
    return selectedIndex;
  }

}
