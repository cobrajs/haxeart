package ;

import nme.net.SharedObject;

class Preferences {
  private var so:SharedObject;
  private var dirty:Bool;

  public var undoSteps(default, setUndoSteps):Int;
  public var lastUsedBrush(default, setLastUsed):Int;

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
      so.data.lastUsedBrush = 2;
      dirty = true;
    }
    lastUsedBrush = so.data.lastUsedBrush;

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

  private function setUndoSteps(steps:Int):Int {
    undoSteps = steps;
    writePref('undoSteps');
    return steps;
  }

  private function setLastUsed(brush:Int):Int {
    lastUsedBrush = brush;
    writePref('lastUsedBrush');
    return brush;
  }
}
