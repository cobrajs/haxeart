package ui.components;

import ui.components.Component;
import ui.layouts.Layout;

class Container extends Component {
  public var layout:Layout;

  public function new() {
    super();

    background = null;
  }

  override public function resize(width:Float, height:Float) {
    super.resize(width, height);

    layout.resize(width, height);
  }
}
