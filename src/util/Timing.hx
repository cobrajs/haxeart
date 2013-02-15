package util;

class Timing {
  public static function getTime():Float {
#if (neko || cpp)
    return Sys.time();
#else
    return Date.now().getTime() / 1000;
#end
  }

  public static function timeFunction(func:Void->Void) {
    var start = getTime();
    func();
    return getTime() - start;
  }
}
