package util;

// Implementation of Bresenham's line algorithm

class LineIter {
  // Line position vars
  var x0:Int;
  var x1:Int;
  var y0:Int;
  var y1:Int;

  // Algorithm vars
  var dx:Int;
  var dy:Int;
  var sx:Int;
  var sy:Int;
  var err:Int;
  var e2:Int;

  public function new(x0:Int, y0:Int, x1:Int, y1:Int) {
    this.x0 = x0;
    this.y0 = y0;
    this.x1 = x1;
    this.y1 = y1;

    dx = Math.floor(Math.abs(x1 - x0));
    dy = Math.floor(Math.abs(y1 - y0));

    sx = (x0 < x1) ? 1 : -1;
    sy = (y0 < y1) ? 1 : -1;

    err = dx - dy;
  }

  public function hasNext() {
    return !(x0 == x1 && y0 == y1);
  }

  public function next() {
    var ret = [x0, y0];

    e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x0 += sx;
    }
    if (e2 < dx) {
      err += dx;
      y0 += sy;
    }

    return ret;
  }
}

