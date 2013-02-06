package ui.layouts;

import ui.components.Component;

class Layout {
  public var width(default, null):Float;
  public var height(default, null):Float;
  public var components(default, null):Array<Component>;
  public var packed:Bool;

  public function new(width:Float, height:Float) {
    components = new Array<Component>();

    this.width = width;
    this.height = height;

    packed = false;
  }

  public function addComponent(component:Component) {
    if (!packed) {
      components.push(component);
    }
    else {
      throw "No components may be added after packing";
    }
  }

  public function pack() {
    packed = true;
  }

  public function resize(width:Float, height:Float) {
    this.width = width;
    this.height = height;
    if (packed) {
      pack();
    }
  }
}

