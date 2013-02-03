package graphics;

import nme.display.BitmapInt32;
import nme.display.BitmapData;
import nme.geom.ColorTransform;

class Color {
#if neko
  public static var transparent:BitmapInt32 = {rgb: 0x000000, a: 0x00};
#else
  public static var transparent:BitmapInt32 = 0x00000000;
#end
  
  public var colorInt:Int;
  public var alpha:Int;
  public var colorARGB(getARGBcolor, setARGBcolor):BitmapInt32;

  public static function getARGB(color:Int, alpha:Int):BitmapInt32 {
#if neko
    return {rgb: color, a:alpha};
#else
    return (alpha << 24) | color;
#end
  }

  public static function generateTransform(color:Int) {
    return 
      new ColorTransform(1, 1, 1, 1,
        (color & (0xFF << 16)) >> 16, // R
        (color & (0xFF << 8)) >> 8,   // G
        color & 0xFF                  // B
      );
  }

  public static function stringToColor(color:String, ?parts:Int = 3) {
    if (color.length != parts * 2) {
      throw "Invalid color for part size";
    }

    var retColor:Int = 0;
    var use:Int = 0, charCode:Int = 0;
    for (i in 0...parts * 2) {
      charCode = color.charCodeAt(i);
      if (charCode >= 48 && charCode <= 57) {
        use = charCode - 48;
      }
      else if (charCode >= 65 && charCode <= 70) {
        use = charCode - 65 + 10;
      }
      else if (charCode >= 97 && charCode <= 102) {
        use = charCode - 97 + 10;
      }
      retColor |= use << (i * 4);
    }
    
    return retColor;
  }

  //
  // Instance methods
  //

  public function new(colorInt:Int, ?alpha:Int = 0xFF) {
    this.colorInt = colorInt;
    this.alpha = alpha;
  }

  //
  // Property getter/setters
  // 
  
  private function getARGBcolor():BitmapInt32 {
    return Color.getARGB(this.colorInt, this.alpha);
  }

  private function setARGBcolor(color:BitmapInt32):BitmapInt32 {
#if neko
    // BitmapInt32: {rgb: rgb, a: a}
    this.colorInt = color.rgb;
    this.alpha = color.a;
#else
    // BitmapInt: 0xAARRGGBB
    this.alpha = color >> 24;
    this.colorInt = color & (0xFFFFFF);
#end
    return color;
  }
}
