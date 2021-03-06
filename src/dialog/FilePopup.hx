package dialog;

import util.FileManager;

import cobraui.popup.Popup;
import cobraui.popup.PopupEvent;
import cobraui.popup.PromptPopup;
import cobraui.util.ScrollBox;
import cobraui.components.Component;
import cobraui.components.Container;
import cobraui.components.Label;
import cobraui.components.SimpleButton;
import cobraui.layouts.BorderLayout;
import cobraui.layouts.GridLayout;
import cobraui.graphics.Tilesheet;

import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.Assets;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class FilePopup extends Popup {
  private var preview:Sprite;

  private var tempBitmapData:BitmapData;

  private var scrollBox:ScrollBox;
  private var fileListBoxes:Array<Sprite>;
  private var fileList:Array<FileInfo>;
  private var parentDir:FileInfo;

  private var buttonBar:Container;

  private var icons:Tilesheet;

  private var fileHeight:Float;

  private var selected:Int;

  public function new(width:Float, height:Float) {
    super(width, height, "Files", BorderLayout.MIDDLE, false);

    icons = new Tilesheet(Assets.getBitmapData("assets/fileicons.png"), 2, 2);

    fileHeight = 32;
    selected = -1;

    // For inserting at the start of a list
    parentDir = {
      name : '..',
      isDir : true,
      size : 0
    };

    fileList = new Array<FileInfo>();
    fileListBoxes = new Array<Sprite>();

    preview = new Sprite();
    preview.visible = false;

    preview.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent) {
      Registry.canvas.loadFromData(tempBitmapData);
      hide();
    });
    window.addChild(preview);

    scrollBox = new ScrollBox(Std.int(uWidth / 2), Std.int(uHeight));
    window.addChild(scrollBox);

    //
    // Setup bottom button bar

    buttonBar = new Container();
    buttonBar.layout = new GridLayout(10, 10, 0, 1);
    var tempButton = new SimpleButton<String>("Save");
    tempButton.onClick = function(event:MouseEvent) {
      var tempPopup = new PromptPopup(selected == -1 ? '' : fileList[selected].name);
      tempPopup.addAllowed(~/[A-Za-z._-]/);
      addChild(tempPopup);
      tempPopup.popup();
      var id = tempPopup.id;
      var msgFnc:PopupEvent->Void = null;
      msgFnc = function(e:PopupEvent) {
        if (e.id == id) {
          if (e.message != "" && e.message != null) {
            Registry.fileManager.saveFile(e.message, Registry.canvas.getCanvas());
            tempPopup.hide();
            removeEventListener(PopupEvent.MESSAGE, msgFnc);
            removeChild(tempPopup);
            this.hide();
          }
        }
      };

      addEventListener(PopupEvent.MESSAGE, msgFnc);
    };
    buttonBar.layout.addComponent(tempButton);
    buttonBar.addChild(tempButton);
    tempButton = new SimpleButton<String>("Load");
    tempButton.onClick = function(event:MouseEvent) {
      if (tempBitmapData != null) {
        Registry.canvas.loadFromData(tempBitmapData);
        this.hide();
      }
    };
    buttonBar.addChild(tempButton);
    buttonBar.layout.addComponent(tempButton);
    tempButton = new SimpleButton<String>("Cancel");
    tempButton.onClick = function(event:MouseEvent) {
      this.hide();
    };
    buttonBar.addChild(tempButton);
    buttonBar.layout.addComponent(tempButton);
    buttonBar.layout.pack();

    // 
    // Setup layout for buttons and labels

    layout = new BorderLayout(uWidth, uHeight);
    window.addChild(buttonBar);
    layout.assignComponent(buttonBar, BorderLayout.BOTTOM_RIGHT, 0.5, 0.15, percent);
    var tempLabel = new Label<String>("Preview");
    tempLabel.borderWidth = 2;
    tempLabel.vAlign = middle;
    tempLabel.hAlign = center;
    //tempLabel.background = null;
    window.addChild(tempLabel);
    layout.assignComponent(tempLabel, BorderLayout.TOP_RIGHT, 0.5, 0.08, percent);

    // Add scrollbox to layout
    layout.assignComponent(scrollBox, BorderLayout.LEFT, 0.5, 1, percent);

    layout.pack();

    updateFileList();
  }

  override private function sizeToStage() {
    super.sizeToStage();

    //scrollBox.resize(Std.int(uWidth / 2), Std.int(uHeight));
    updateFileList();
  }

  private function updateFileList() {
    fileList = Registry.fileManager.listDir();
    fileList.unshift(parentDir);
    for (i in 0...fileList.length) {
      if (i < fileListBoxes.length) {
        fileListBoxes[i].visible = true;
        updateFileListItem(fileListBoxes[i], fileList[i]);
      }
      else {
        addFileListItem(fileList[i]);
      }
    }
    for (i in fileList.length...fileListBoxes.length) {
      fileListBoxes[i].visible = false;
    }
  }

  private function addFileListItem(file:FileInfo) {
    var temp = new Sprite();
    updateFileListItem(temp, file);
    temp.y = fileListBoxes.length * fileHeight;
    fileListBoxes.push(temp);
    scrollBox.scrollBox.addChild(temp);
  }

  private function updateFileListItem(fileItem:Sprite, file:FileInfo, ?selected:Bool = false) {
    var gfx = fileItem.graphics;
    gfx.clear();
    gfx.beginFill(selected ? 0xAAAAAA : 0xEEEEEE);
    gfx.drawRect(0, 0, uWidth / 2, fileHeight);
    gfx.endFill();
    icons.drawTiles(gfx, [0, 0, file.isDir ? 0 : 1]);
    
    Registry.font.drawText(gfx, Std.int(fileHeight + 5), 5, file.name);
  }

  override function onMouseUp(event:MouseEvent) {
    if (event.target == closeButton) {
      hide();
    }

    for (i in 0...fileListBoxes.length) {
      if (event.target == fileListBoxes[i]) {
        if (selected == i) {
          var file = fileList[i];
          preview.visible = false;
          if (file.isDir) {
            Registry.fileManager.changeDir(file.name);
            updateFileList();
            selected = -1;
            scrollBox.scrollTop();
            tempBitmapData = null;
          }
          else {
            var gfx = preview.graphics;
            tempBitmapData = Registry.fileManager.loadPreview(file.name);
            if (tempBitmapData != null) {
              gfx.clear();
              gfx.beginBitmapFill(tempBitmapData);
              gfx.drawRect(0, 0, tempBitmapData.width, tempBitmapData.height);
              preview.visible = true;
              if (tempBitmapData.width > uWidth / 2) {
                var zoom = (uWidth / 2) / tempBitmapData.width;
                preview.scaleX = zoom;
                preview.scaleY = zoom;
              }
              else if (tempBitmapData.height > uHeight) {
                var zoom = (uHeight) / tempBitmapData.height;
                preview.scaleX = zoom;
                preview.scaleY = zoom;
              }
              else {
                preview.scaleX = 1;
                preview.scaleY = 1;
              }
              preview.y = (uHeight / 2) - (preview.height / 2);
              preview.x = (uWidth / 2) + (uWidth / 4) - (preview.width / 2);
            }
          }
        }
        else {
          if (selected != -1) {
            updateFileListItem(fileListBoxes[selected], fileList[selected], false);
          }
          selected = i;
          updateFileListItem(fileListBoxes[selected], fileList[selected], true);
        }
      }
    }
  }
}
