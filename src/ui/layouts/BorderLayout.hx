package ui.layouts;

import ui.components.Component;
import ui.layouts.Layout;

/*

   The border layout sticks components in specified corners or edges
   Each component needs a place for it, and a desired width and height
    specified by either pixels or percents of the screen

   Available position specifications:
   TOP_LEFT          TOP           TOP_RIGHT

   LEFT             MIDDLE             RIGHT

   BOTTOM_LEFT      BOTTOM      BOTTOM_RIGHT

*/

typedef Slot = {
  var width:Float;
  var height:Float;
  var type:SizeType;
  var position:Int;
  var occupant:Component;
}

class BorderLayout extends Layout {
  // These are from binary anding the vertical and horizontal positions
  public static var TOP_LEFT:Int = 9;
  public static var TOP:Int = 17;
  public static var TOP_RIGHT:Int = 33;
  public static var LEFT:Int = 10;
  public static var MIDDLE:Int = 18;
  public static var RIGHT:Int = 34;
  public static var BOTTOM_LEFT:Int = 12;
  public static var BOTTOM:Int = 20;
  public static var BOTTOM_RIGHT:Int = 36;

  public static var IS_TOP_EDGE:Int = 1;
  public static var IS_LEFT_EDGE:Int = 8;
  public static var IS_RIGHT_EDGE:Int = 32;
  public static var IS_BOTTOM_EDGE:Int = 4;
  public static var IS_MIDDLE_HORIZONTAL:Int = 16;
  public static var IS_MIDDLE_VERTICAL:Int = 2;

  public var slots:IntHash<Slot>;

  public function new(width:Float, height:Float) {
    super(width, height);

    slots = new IntHash<Slot>();
  }

  override public function addComponent(component:Component) {
    throw "Invalid call. Use assignComponent for this Layout type";
  }

  override public function assignComponent(component:Component, position:Int, width:Float, height:Float, type:SizeType) {
    if (slots.exists(position)) {
      //throw "Component already exists in this position";
      slots.remove(position);
    }

    var tempSlot:Slot = {
      width: width,
      height: height,
      position: position,
      occupant: component,
      type: type
    };

    super.addComponent(component);

    slots.set(position, tempSlot);
  }

  override public function pack(?offsetX:Float = 0, ?offsetY:Float = 0) {
    super.pack();

    for (key in slots.keys()) {
      var slot = slots.get(key);
      var width = slot.width;
      var height = slot.height;
      if (slot.type == percent) {
        width = slot.width * this.width;
        height = slot.height * this.height;
      }
      var x = (key == TOP_LEFT || key == LEFT || key == BOTTOM_LEFT) ? 0 :
              (key == TOP || key == MIDDLE || key == BOTTOM) ? this.width / 2 - width / 2 :
              this.width - width;
      var y = (key == TOP_LEFT || key == TOP || key == TOP_RIGHT) ? 0 :
              (key == LEFT || key == MIDDLE || key == RIGHT) ? this.height / 2 - height / 2 :
              this.height - height;
      slot.occupant.resize(width, height);
      slot.occupant.x = x + offsetX;
      slot.occupant.y = y + offsetY;
    }
  }
}

