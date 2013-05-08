package dialog;

import cobraui.popup.Popup;

import cobraui.components.Container;
import cobraui.components.Label;
import cobraui.components.Selector;
import cobraui.components.SimpleButton;
import cobraui.components.Slider;

import cobraui.layouts.BorderLayout;
import cobraui.layouts.GridLayout;

import nme.events.Event;
import nme.events.MouseEvent;

class PreferencesPopup extends Popup {

  public static var numberOfPrefs:Int = 2;

  public function new() {
    super(0.8, 0.8, "Preferences", BorderLayout.MIDDLE, false);

    layout = new BorderLayout(uWidth, uHeight);

    var tempContainer = new Container();
    tempContainer.layout = new GridLayout(10, 10, 2, numberOfPrefs);
    layout.assignComponent(tempContainer, BorderLayout.TOP, 1, 0.8, percent);
    window.addChild(tempContainer);

    // Undo Steps pref

    var tempLabel = new Label<String>("Undo Steps");
    tempLabel.hAlign = center;
    tempContainer.layout.addComponent(tempLabel);
    tempContainer.addChild(tempLabel);

    var tempSlider = new Slider(1, 20, Registry.prefs.undoSteps);
    tempSlider.addEventListener(Event.CHANGE, function(e:Event) {
      Registry.prefs.undoSteps = tempSlider.value;
    });
    tempContainer.layout.addComponent(tempSlider);
    tempContainer.addChild(tempSlider);

    // Keep Last Brush pref

    tempLabel = new Label<String>("Keep Last Brush");
    tempLabel.hAlign = center;
    tempContainer.layout.addComponent(tempLabel);
    tempContainer.addChild(tempLabel);

    var tempSelector = new Selector<String>(Registry.prefs.keepLastBrush ? ["True", "False"] : ["False", "True"]);
    tempSelector.addEventListener(Event.CHANGE, function(e:Event) {
      Registry.prefs.keepLastBrush = tempSelector.selected == "True";
    });
    tempContainer.layout.addComponent(tempSelector);
    tempContainer.addChild(tempSelector);

    tempContainer.layout.pack();

    // Last button

    var tempButton = new SimpleButton<String>("Save");
    tempButton.onClick = function(event:MouseEvent) {
      this.hide();
    };
    layout.assignComponent(tempButton, BorderLayout.BOTTOM, 1, 0.2, percent);
    window.addChild(tempButton);

    layout.pack();
  }

}
