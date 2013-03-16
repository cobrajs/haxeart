package graphics;

import cobraui.graphics.Color;

import nme.Assets;

class PaletteFactory {
  private var colors:Array<Int>;

  public function new() {
    colors = new Array<Int>();
  }

  public function load(filename:String) {
    var text = Assets.getText("assets/" + filename);
    var rawColors = text.split("\n");
    for (color in rawColors) {
      if (color != "" && color.charAt(0) != "'") {
        colors.push(Color.stringToColor(color));
      }
    }
  }

  public function getColors():Array<Int> {
    return colors;
  }
}
