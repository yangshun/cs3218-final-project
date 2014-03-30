$.extend({
  initWithFrame: function(imgName, arr, rot) {
    // arr: [originX, originY, width, height]
    // rot: angle of clockwise rotation (in degrees)
    var $obj = $('<img>', { src: 'img/' + imgName });
    $obj.css('width', arr[2]);
    $obj.css('height', arr[3]);
    $obj.css('transform', 'matrix(1, 0, 0, 1,'+arr[0]+','+arr[1]+')');
    $obj.setRotation(rot);
    return $obj;
  }
});

$.fn.extend({
  transformMatrix: function() {
    return _.map(this.css('transform').toString().match(/(-?[0-9\.]+)/g), function(num) { 
      return parseFloat(num); 
    });
  },
  setTransformMatrix: function(arr) {
    var mat = _.map(arr, function(val) {
      return val.toFixed(6);
    });
    this.css('transform', 'matrix(' + mat.join() + ')');
  }, 
  getX: function() {
    return this.transformMatrix()[4] + parseFloat(this.width()/2);
  },
  setX: function(x) {
    var mat = this.transformMatrix();
    var originX = x - parseFloat(this.width())/2;
    mat[4] = originX;
    this.setTransformMatrix(mat);
  },
  translateX: function(x) {
    this.setX(this.getX() + x);
  },
  getY: function() {
    return this.transformMatrix()[5] + parseFloat(this.height()/2);
  },
  setY: function(y) {
    var mat = this.transformMatrix();
    var originY = y - parseFloat(this.height())/2;
    mat[5] = originY;
    this.setTransformMatrix(mat);
  },
  translateY: function(y) {
    this.setY(this.getY() + y);
  },
  getCenter: function() {
    return { x: this.getX(), y: this.getY() };
  },
  setCenter: function(x, y) {
    this.setX(x);
    this.setY(y);
  },
  getRotation: function() {
    var mat = this.transformMatrix();
    var a = mat[0];
    var b = mat[1];
    var scale = Math.sqrt(a*a + b*b);
    var sin = b/scale;
    var angle = Math.round(Math.atan2(b, a) * (180/Math.PI));
    return angle;
  },
  setRotation: function(rot) {
    var mat = this.transformMatrix();
    var angle = rot/180 * Math.PI;
    this.setTransformMatrix([Math.cos(angle), Math.sin(angle), -Math.sin(angle), Math.cos(angle), mat[4], mat[5]]);
  },
  rotate: function(rot) {
    // Rotates clockwise by rot (in degrees)
    var mat = this.transformMatrix();
    var angle = rot/180 * Math.PI;
    var a = mat[0];
    var b = mat[1];
    var c = mat[2];
    var d = mat[3];
    mat[0] = a*Math.cos(angle) - b*Math.sin(angle);
    mat[1] = a*Math.sin(angle) + b*Math.cos(angle);
    mat[2] = c*Math.cos(angle) - d*Math.sin(angle);
    mat[3] = c*Math.sin(angle) + d*Math.cos(angle);
    this.setTransformMatrix(mat);
  }
});
