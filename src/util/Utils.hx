package util;

class Utils {
  public static function curry(func:Dynamic, arg:Dynamic):Void->Void {
    return function() { func(arg); }
  }
  
  public static function weightedRandom(array:Array<Dynamic>, weights:Array<Float>) {
    var total:Float = 0;

    for (weight in weights) {
      total += weight;
    }

    var pick = Math.random() * total;
    var previous:Float = 0;
    var tempTotal:Float = 0;
    for (i in 0...weights.length) {
      if (pick >= previous && pick < weights[i] + tempTotal) {
        return array[i];
      }
      previous = weights[i];
      tempTotal += previous;
    }

    return array[Std.random(array.length)];
  }
}
