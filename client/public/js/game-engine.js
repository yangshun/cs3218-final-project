var FRAME_RATE = 30;
var SPAWN_AMOUNT = 2;
var CANVAS_WIDTH;
var CANVAS_HEIGHT;
var gameitems = [];

function init() {
  
}

function generateItem() {
  for (var i = 0; i < SPAWN_AMOUNT; i++) {
    var rocket = $.initWithFrame('rocket.png', [utils.getRandomInt(50, CANVAS_WIDTH - 50), 0, 50], 90);
    gameitems.push(rocket);
    $('#canvas').append(rocket);
  }
}

function removeOutOfScreen() {
  var removal = [];
  removal = _.filter(gameitems, function(item) {
    return item.getY() > CANVAS_HEIGHT;
  });
  _.each(removal, function(item) {
    item.remove();
  });
  gameitems = _.difference(gameitems, removal);
}

function tick() {
  _.each(gameitems, function(item) {
    item.translateY(1);
  })
  removeOutOfScreen();
  console.log(gameitems.length);
}

$(function() {
  CANVAS_WIDTH = $('#canvas').width();
  CANVAS_HEIGHT = $('#canvas').height();
  init();
  setInterval(tick, 1/FRAME_RATE);
  setInterval(generateItem, 3000);
});
