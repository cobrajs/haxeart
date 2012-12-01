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

  public static function keyImage(imageData:BitmapData, ?colorKey:Int = 0xFF00FF) {
    imageData.lock();
    for (y in 0...cast(imageData.height, Int)) {
      for (x in 0...cast(imageData.width, Int)) {
        if (imageData.getPixel(x, y) == colorKey) {
          imageData.setPixel32(x, y, transparent);
        }
      }
    }
    imageData.unlock();
  }

  public static function getARGB(color:Int, alpha:Int):BitmapInt32 {
#if neko
    return {rgb: color, a:alpha};
#else
    return (alpha << 24) & color;
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
}
