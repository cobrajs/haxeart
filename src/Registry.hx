package ;

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
}
