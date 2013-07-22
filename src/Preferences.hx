package ;

import flash.net.SharedObject;

class Preferences {
  private var so:SharedObject;
  private var dirty:Bool;

  public var undoSteps (default, set):Int;
  public var lastUsedBrush (default, set):Int;
  public var keepLastBrush (default, set):Bool;

  public var paletteX (default, set):Int;
  public var paletteY (default, set):Int;

  public function new() {
    so = SharedObject.getLocal("haxeart-prefs");
    dirty = false;

    // Set defaults and load values
    if (so.data.undoSteps == null) {
      so.data.undoSteps = 5;
      dirty = true;
    } 
    undoSteps = so.data.undoSteps;

    if (so.data.lastUsedBrush == null) {
      so.data.lastUsedBrush = 1;
      dirty = true;
    }
    lastUsedBrush = so.data.lastUsedBrush;

    if (so.data.keepLastBrush == null) {
      so.data.keepLastBrush = true;
      dirty = true;
    } 
    keepLastBrush = so.data.keepLastBrush;

    if (so.data.paletteX == null) {
      so.data.paletteX = 3;
      dirty = true;
    }
    paletteX = so.data.paletteX;

    if (so.data.paletteY == null) {
      so.data.paletteY = 3;
      dirty = true;
    }
    paletteY = so.data.paletteY;

    if (dirty) {
      so.flush();
    }
  }

  private function writePref(prefName:String) {
    var pref:Dynamic = Reflect.field(this, prefName);
    Reflect.setField(so.data, prefName, pref);

    try {
      so.flush();
    } catch(e:Dynamic) {
      trace("Could not write preference: " + prefName);
    }
  }

  private function set_undoSteps(steps:Int):Int {
    undoSteps = steps;
    writePref('undoSteps');
    return steps;
  }

  private function set_lastUsedBrush(brush:Int):Int {
    lastUsedBrush = brush;
    writePref('lastUsedBrush');
    return brush;
  }
  
  private function set_keepLastBrush(keepLast:Bool):Bool {
    keepLastBrush = keepLast;
    writePref('keepLastBrush');
    return keepLast;
  }
  
  private function set_paletteX(x:Int):Int {
    paletteX = x;
    writePref('paletteX');
    return paletteX;
  }
  
  private function set_paletteY(y:Int):Int {
    paletteY = y;
    writePref('paletteY');
    return paletteY;
  }
  
}
