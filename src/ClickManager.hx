package ;

import ClickEvent;

import util.Utils;

import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

class ClickManager {
  public static var HOLDTIME = 0.5;
  public static var maxTravel = 20;
  private var data:Map<String,HoldData>;

  private var lastUpdate:Float;

  public function new(stage:Stage) {
    data = new Map<String,HoldData>();

    lastUpdate = Utils.getTime();
    stage.addEventListener(Event.ENTER_FRAME, update);
  }

  public function registerComponent(component:InteractiveObject, ?holdTime:Float, ?multiple:Bool = false) {
    var name = component.name;
    var tempData = new HoldData(component, holdTime == null ? HOLDTIME : holdTime, multiple);

    component.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
      tempData.held = true;
      tempData.usable = true;

      tempData.pos.x = e.stageX;
      tempData.pos.y = e.stageY;

      tempData.localPos.x = e.localX;
      tempData.localPos.y = e.localY;

      tempData.time = 0;
    });

    component.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
      if (tempData.held) {
        if (Math.abs(tempData.pos.x - e.stageX) > maxTravel || Math.abs(tempData.pos.y - e.stageY) > maxTravel) {
          tempData.pos.x = e.stageX;
          tempData.pos.y = e.stageY;

          tempData.localPos.x = e.localX;
          tempData.localPos.y = e.localY;

          tempData.time = 0;
        }
      }
    });

    var upAndOut = function(e:MouseEvent) {
      tempData.held = false;
      tempData.usable = false;
    };

    component.addEventListener(MouseEvent.MOUSE_UP, upAndOut);
    component.addEventListener(MouseEvent.MOUSE_OUT, upAndOut);

    data.set(name, tempData);
  }

  public function update(dt:Float) {
    var time = Utils.getTime();
    var dt = time - lastUpdate;

    for (tempData in data.iterator()) {
      if (tempData.held && tempData.usable) {
        tempData.time += dt;
        if (tempData.time >= tempData.holdTime) {
          tempData.component.dispatchEvent(new ClickEvent(ClickEvent.HOLD_CLICK, 
                tempData.pos.x, tempData.pos.y,
                tempData.localPos.x, tempData.localPos.y));
          if (tempData.multiple) {
            tempData.time = 0;
          } else {
            tempData.held = false;
            tempData.usable = false;
          }
        }
      }
    }

    lastUpdate = time;
  }
}

class HoldData {
  public var held:Bool;
  public var usable:Bool;
  public var pos:Point;
  public var localPos:Point;
  public var time:Float;
  public var holdTime:Float;
  public var multiple:Bool;
  public var component:InteractiveObject;

  public function new(component:InteractiveObject, holdTime:Float, ?multiple:Bool = false) {
    this.component = component;

    this.held = false;
    this.usable = false;

    this.pos = new Point(0, 0);
    
    this.localPos = new Point(0, 0);
    
    this.time = 0; 
    this.holdTime = holdTime;

    this.multiple = multiple;
  }
}
