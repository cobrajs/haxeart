package dialog;

import cobraui.popup.Popup;

import cobraui.components.Container;
import cobraui.components.Label;
import cobraui.components.Selector;
import cobraui.components.SimpleButton;
import cobraui.components.Slider;

import cobraui.layouts.BorderLayout;
import cobraui.layouts.GridLayout;

import ui.CustomEvents;

import flash.events.Event;
import flash.events.MouseEvent;

class PreferencesPopup extends Popup {

  public static var numberOfPrefs:Int = 4;

  private var changedPalette:Bool;

  public function new() {
    super(0.8, 0.8, "Preferences", BorderLayout.MIDDLE, false);

    changedPalette = false;

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
      Registry.prefs.undoSteps = tempSlider.getValue();
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

    // Palette X

    var tempLabel = new Label<String>("Palette X");
    tempLabel.hAlign = center;
    tempContainer.layout.addComponent(tempLabel);
    tempContainer.addChild(tempLabel);

    var tempSlider = new Slider(1, 8, Registry.prefs.paletteX);
    tempSlider.addEventListener(Event.CHANGE, function(e:Event) {
      Registry.prefs.paletteX = tempSlider.getValue();
      changedPalette = true;
    });
    tempContainer.layout.addComponent(tempSlider);
    tempContainer.addChild(tempSlider);

    // Palette X

    var tempLabel = new Label<String>("Palette Y");
    tempLabel.hAlign = center;
    tempContainer.layout.addComponent(tempLabel);
    tempContainer.addChild(tempLabel);

    var tempSlider = new Slider(1, 8, Registry.prefs.paletteY);
    tempSlider.addEventListener(Event.CHANGE, function(e:Event) {
      Registry.prefs.paletteY = tempSlider.getValue();
      changedPalette = true;
    });
    tempContainer.layout.addComponent(tempSlider);
    tempContainer.addChild(tempSlider);

    tempContainer.layout.pack();

    // Last button

    var tempButton = new SimpleButton<String>("Save");
    tempButton.onClick = function(event:MouseEvent) {
      this.hide();
      if (changedPalette) {
        stage.dispatchEvent(new CustomEvents(CustomEvents.RESIZE_PALETTE, ""));
      }
    };
    layout.assignComponent(tempButton, BorderLayout.BOTTOM, 1, 0.2, percent);
    window.addChild(tempButton);

    layout.pack();
  }

  override public function popup() {
    super.popup();

    changedPalette = false;
  }

}
