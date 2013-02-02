package ui.layouts;

/*

   The grid layout should be given an even number of components
   It will try to arrange them automatically when packed, but
   it also takes sizeX and sizeY to force the sizes
   Setting either sizeX or sizeY to 0 and setting the opposite
   to a number will (for example) force sizeX to be 2 and expand sizeY to fit the height

   Auto: 
   +---+---+---+
   |   |   |   |
   +---+---+---+
   |   |   |   |
   +---+---+---+

   sizeX: 6, sizeY: 1 :
   +-+-+-+-+-+-+
   | | | | | | |
   | | | | | | |
   | | | | | | |
   +-+-+-+-+-+-+

   sizeX: 2, sizeY: 0 :

   +-----+-----+
   +-----+-----+
   +-----+-----+
   +-----+-----+

*/

import ui.components.Component;

class GridLayout {
  public var width(default, null):Float;
  public var height(default, null):Float;
  public var components(default, null):Array<Component>;
  public var sizeX:Int;
  public var sizeY:Int;
  public var packed:Bool;

  public function new(width:Float, height:Float, ?sizeX:Int = 0, ?sizeY:Int = 0) {
    components = new Array<Component>();

    this.sizeX = sizeX;
    this.sizeY = sizeY;

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

    if (sizeX == 0 && sizeY != 0) {
      sizeX = Math.ceil(components.length / sizeY);
    }
    else if (sizeX != 0 && sizeY == 0) {
      sizeY = Math.ceil(components.length / sizeX);
    }
    else if (sizeX == 0 && sizeY == 0) {
      var bestDif:Float = 999;
      var bestI:Int = -1;
      for (i in 1...Std.int(Math.min(components.length+1, 10))) {
        var tempDif = Math.abs((width / i) - (height / Math.ceil(components.length / i)));
        if (tempDif < bestDif) {
          bestDif = tempDif;
          bestI = i;
        }
      }
      if (bestI == -1) {
        bestI = 1;
      }
      sizeX = bestI;
      sizeY = Math.ceil(components.length / bestI);
    }

    var x = 0;
    var y = 0;
    var componentWidth = width / sizeX;
    var componentHeight = height / sizeY;
    for (i in 0...components.length) {
      x = i % sizeX;
      y = Std.int(i / sizeX);
      components[i].resize(componentWidth, componentHeight);
      components[i].x = x * componentWidth;
      components[i].y = y * componentHeight;
    }

  }

  public function resize(width:Float, height:Float) {
    this.width = width;
    this.height = height;
    if (packed) {
      pack();
    }
  }
}
