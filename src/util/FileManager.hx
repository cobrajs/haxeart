package util;

import nme.filesystem.File;
import nme.display.BitmapData;

typedef FileInfo = {
  var name:String;
  var isDir:Bool;
  var size:Float;
};

class FileManager {
  public var currentDir:String;

  public function new(?defaultDir:String) {
    if (defaultDir == null) {
#if linux 
      currentDir = File.userDirectory.nativePath;
#elseif android
      currentDir = File.documentsDirectory.nativePath; 
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
      var rawData = sys.io.File.getBytes(fullName);
      data = BitmapData.loadFromHaxeBytes(rawData);
    }
#end
    return data;
  }
}
