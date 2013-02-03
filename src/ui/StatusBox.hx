package ui;

// TODO: Make the status box work

import ui.components.Component;

import nme.display.BitmapData;

class StatusBox extends Component {
  public var brushImage:BitmapData;
  public var currentColor:Color;

  public function new(brushImage, currentColor) {
    this.brushImage = brushImage;
    this.currentColor = currentColor;
  }

  override public function redraw() {
    if (ready) {
      super.redraw();
    }
  }
}
