package ;

import ClickEvent;

import util.Utils;

import nme.display.InteractiveObject;
import nme.display.Stage;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;

class ClickManager {
  public static var holdTime = 0.5;
  public static var maxTravel = 20;
  private var data:Hash<HoldData>;

  private var lastUpdate:Float;

  public function new(stage:Stage) {
    data = new Hash<HoldData>();

    lastUpdate = Utils.getTime();
    stage.addEventListener(Event.ENTER_FRAME, update);
  }

  public function registerComponent(component:InteractiveObject) {
    var name = component.name;
    var tempData = new HoldData(component);

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
      if (Math.abs(tempData.pos.x - e.stageX) > maxTravel || Math.abs(tempData.pos.y - e.stageY) > maxTravel) {
        tempData.usable = false;
      }
    });

    component.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) {
      tempData.held = false;
      tempData.usable = false;
    });

    data.set(name, tempData);
  }

  public function update(dt:Float) {
    var time = Utils.getTime();
    var dt = time - lastUpdate;

    for (tempData in data.iterator()) {
      if (tempData.held && tempData.usable) {
        tempData.time += dt;
        if (tempData.time >= holdTime) {
          tempData.component.dispatchEvent(new ClickEvent(ClickEvent.HOLD_CLICK, 
                tempData.pos.x, tempData.pos.y,
                tempData.localPos.x, tempData.localPos.y));
          tempData.held = false;
          tempData.usable = false;
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
  public var component:InteractiveObject;

  public function new(component:InteractiveObject) {
    this.component = component;

    this.held = false;
    this.usable = false;

    this.pos = new Point(0, 0);
    
    this.localPos = new Point(0, 0);
    
    this.time = 0; 
  }
}
