package dialog;

import cobraui.popup.Popup;
import cobraui.popup.PopupEvent;

import cobraui.components.Component;
import cobraui.components.Container;
import cobraui.components.Label;
import cobraui.components.SimpleButton;
import cobraui.components.Slider;

import cobraui.layouts.BorderLayout;
import cobraui.layouts.GridLayout;

import flash.events.MouseEvent;

class NewPopup extends Popup {
  public static var TYPE:String = "new";

  private var widthSlider:Slider;
  private var heightSlider:Slider;

  public function new(width:Float, height:Float) {
    super(width, height, "New Image", BorderLayout.MIDDLE, false);

    layout = new BorderLayout(uWidth, uHeight);

    //
    // Setup Sliders

    var slideContainer = new Container();
    slideContainer.layout = new GridLayout(10, 10, 1, 0);

    var widthLabel = new Label<String>("Width");
    widthLabel.hAlign = center;
    slideContainer.addChild(widthLabel);
    slideContainer.layout.addComponent(widthLabel);

    widthSlider = new Slider(1, 256, 32);
    slideContainer.addChild(widthSlider);
    slideContainer.layout.addComponent(widthSlider);

    var heightLabel = new Label<String>("Height");
    heightLabel.hAlign = center;
    slideContainer.addChild(heightLabel);
    slideContainer.layout.addComponent(heightLabel);

    heightSlider = new Slider(1, 256, 32);
    slideContainer.addChild(heightSlider);
    slideContainer.layout.addComponent(heightSlider);

    slideContainer.layout.pack();
    layout.assignComponent(slideContainer, BorderLayout.TOP, 1, 0.8, percent);
    window.addChild(slideContainer);

    //
    // Setup bottom button bar

    var buttonBar = new Container();
    buttonBar.layout = new GridLayout(10, 10, 0, 1);
    var tempButton = new SimpleButton<String>("Cancel");
    tempButton.onClick = function(event:MouseEvent) {
      this.hide();
    };
    buttonBar.layout.addComponent(tempButton);
    buttonBar.addChild(tempButton);
    tempButton = new SimpleButton<String>("Ok");
    tempButton.onClick = function(event:MouseEvent) {
      dispatchEvent(new PopupEvent(PopupEvent.CLOSED, TYPE, this.id));
      Registry.canvas.newImage(widthSlider.getValue(), heightSlider.getValue());
      this.hide();
    };
    buttonBar.addChild(tempButton);
    buttonBar.layout.addComponent(tempButton);
    buttonBar.layout.pack();

    layout.assignComponent(buttonBar, BorderLayout.BOTTOM, 1, 0.2, percent);
    window.addChild(buttonBar);

    layout.pack();
  }

}

