package util;

class Utils {
  public static function curry(func:Dynamic, arg:Dynamic):Void->Void {
    return function() { func(arg); }
  }
}
