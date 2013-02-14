package dialog;

import util.FileManager;
import dialog.Popup;
import ui.ScrollBox;
import ui.components.Container;
import ui.components.Label;
import ui.components.SimpleButton;
import ui.layouts.BorderLayout;
import ui.layouts.GridLayout;
import graphics.Tilesheet;

import nme.display.BitmapData;
import nme.display.Sprite;
import nme.Assets;

import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;

class FilePopup extends Popup {
  private var preview:Sprite;

  private var tempBitmapData:BitmapData;

  private var scrollBox:ScrollBox;
  private var fileListBoxes:Array<Sprite>;
  private var fileList:Array<FileInfo>;
  private var parentDir:FileInfo;

  private var layout:BorderLayout;
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

    /*
    addEventListener(Event.ADDED_TO_STAGE, function(e:Event) {
      stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent) {
        if (this.visible) {
          trace(String.fromCharCode(event.charCode));
        }
      });
    });
    */

    scrollBox = new ScrollBox(Std.int(uWidth / 2), Std.int(uHeight));
    window.addChild(scrollBox);

    //
    // Setup bottom button bar

    buttonBar = new Container();
    buttonBar.layout = new GridLayout(10, 10, 0, 1);
    var tempButton = new SimpleButton<String>("Save");
    tempButton.borderWidth = 1;
    tempButton.onClick = function(event:MouseEvent) {
      var tempPopup = new PromptPopup(selected == -1 ? '' : fileList[selected].name);
      addChild(tempPopup);
      tempPopup.popup();
      var id = tempPopup.id;
      var msgFnc:DialogEvent->Void = null;
      msgFnc = function(e:DialogEvent) {
        if (e.id == id) {
          if (e.message != "" && e.message != null) {
            Registry.fileManager.saveFile(e.message, Registry.canvas.getCanvas());
            tempPopup.hide();
            removeEventListener(DialogEvent.MESSAGE, msgFnc);
            removeChild(tempPopup);
            this.hide();
          }
        }
      };

      addEventListener(DialogEvent.MESSAGE, msgFnc);
    };
    buttonBar.layout.addComponent(tempButton);
    buttonBar.addChild(tempButton);
    tempButton = new SimpleButton<String>("Load");
    tempButton.borderWidth = 1;
    tempButton.onClick = function(event:MouseEvent) {
      if (tempBitmapData != null) {
        Registry.canvas.loadFromData(tempBitmapData);
        this.hide();
      }
    };
    buttonBar.addChild(tempButton);
    buttonBar.layout.addComponent(tempButton);
    tempButton = new SimpleButton<String>("Cancel");
    tempButton.borderWidth = 1;
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
    layout.pack();

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
