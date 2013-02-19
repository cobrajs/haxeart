package ;

// TODO: Add Preferences class that uses SharedObject for persistence

import util.FileManager;
import ui.BitmapFont;
import ui.Canvas;
import ui.TouchManager;

import nme.display.Stage;

class Registry {
  public static var touchManager:TouchManager;

  public static var fileManager:FileManager;

  public static var font:BitmapFont;

  public static var stage:Stage;

  public static var canvas:Canvas;

  public static var stageWidth:Float;
  public static var stageHeight:Float;

  public static var prefs:Preferences;

  // Ids for alerts and whatever else wants one
  private static var nextId:Int = 1;
  public static function getNextId():Int {
    return nextId++;
  }
}
