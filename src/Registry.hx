package ;

import cobraui.graphics.BitmapFont;
import cobraui.util.TouchManager;

import ui.Canvas;
import ui.Cursor;
import util.FileManager;

import nme.display.Stage;
import nme.display.Sprite;

class Registry {
  public static var touchManager:TouchManager;

  public static var fileManager:FileManager;

  public static var font:BitmapFont;

  public static var stage:Stage;
  public static var mainWindow:Sprite;

  public static var canvas:Canvas;
  public static var cursor:Cursor;

  public static var stageWidth:Float;
  public static var stageHeight:Float;

  public static var prefs:Preferences;

  // Ids for alerts and whatever else wants one
  private static var nextId:Int = 1;
  public static function getNextId():Int {
    return nextId++;
  }
}
