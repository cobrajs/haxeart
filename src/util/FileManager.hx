package util;

#if (!flash && !js)
import flash.filesystem.File;
#end
import flash.display.BitmapData;

typedef FileInfo = {
  var name:String;
  var isDir:Bool;
  var size:Float;
};

class FileManager {
  public var currentDir:String;

  public function new(?defaultDir:String) {
    if (defaultDir == null) {
#if (!flash && !js)
#if linux 
      currentDir = File.userDirectory.nativePath;
#elseif android
      currentDir = File.documentsDirectory.nativePath; 
#end
#end
    }
    else {
      currentDir = defaultDir;
    }
  }

  public function listDir():Array<FileInfo> {
    var retFiles = new Array<FileInfo>();
#if (!flash && !js)
    var files = sys.FileSystem.readDirectory(currentDir);
    for (file in files) {
      if (file.charAt(0) != '.') {
        var temp:FileInfo = { 
          name: file, 
          isDir: sys.FileSystem.isDirectory(currentDir + '/' + file),
          size: 0
        };
        retFiles.push(temp);
      }
    }
    retFiles.sort(function(a, b) {
      if (a.isDir && !b.isDir) {
        return -1;
      }
      if (!a.isDir && b.isDir) {
        return 1;
      }
      else {
        if (a.name > b.name) {
          return 1;
        }
        else if (a.name < b.name) {
          return -1;
        }
      }
      return 0;
    });
#end
    return retFiles;
  }

  public function changeDir(dir:String):Void {
    if (dir == '..') {
      var parts = currentDir.split('/');
      parts.pop();
      currentDir = parts.join('/');
    }
    else {
      currentDir += '/' + dir;
    }
  }

  public function loadPreview(fileName:String):BitmapData {
    var data:BitmapData = null;
#if (!flash && !js)
    var fullName = currentDir + '/' + fileName;
    if (StringTools.endsWith(fileName, ".png") && 
        sys.FileSystem.exists(fullName)) {
      data = BitmapData.load(fullName);
    }
#end
    return data;
  }

  public function saveFile(fileName:String, data:BitmapData, ?isFullName:Bool = false) {
#if (!flash && !js)
    try {
      var tempBytes = data.encode('png');
      if (!StringTools.endsWith(fileName, ".png")) {
        fileName += ".png";
      }
      var f = sys.io.File.write(isFullName ? fileName : currentDir + '/' + fileName, true); 
      f.writeString(tempBytes.asString());
      f.close();
    } catch (e : Dynamic) {
      trace("Error saving file! " + e);
    }
#end
  }

}
