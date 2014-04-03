var controller = new Leap.Controller({enableGestures: true});

controller.on('deviceConnected', function() {
  console.log("A Leap device has been connected.");
});

controller.on('deviceDisconnected', function() {
  console.log("A Leap device has been disconnected.");
});

controller.on('ready', function(){
  // Ready code will go here
  console.log('Controller ready');
});

var DIRECTION_IDENTIFYING_THRESHOLD = 0.5;

// controller.on('animationFrame', function(frame) {
//   // Frame code goes here
//   // console.log('animationFrame', frame.fingers.length);
//   var gesture = frame.pointables[0];
//   if (gesture) {
//     console.log(gesture.direction);
//     if (gesture) {
//       function clearDirection(direction) {
//         // Ensure that swiping direction is one of the orthogonal directions
//         return Math.abs(Math.abs(direction[0]) - Math.abs(direction[1])) > DIRECTION_IDENTIFYING_THRESHOLD;
//       }
//       function getDirection(direction) {
//         if (Math.abs(gesture.direction[0]) > Math.abs(gesture.direction[1])) {
//           // X-direction
//           if (gesture.direction[0] < 0) {
//             return "left";
//           } else {
//             return "right";
//           }
//         } else {
//           if (gesture.direction[1] < 0) {
//             return "down";
//           } else {
//             return "up";
//           }
//         }
//       }
//       if (clearDirection(gesture.direction)) {
//         // console.log(getDirection(gesture.direction), frame.fingers.length);
//       }
//     }
//   }
// });


// Leap Hand Plugin

// controller.use('screenPosition', {
//   positioning: function(positionVec3) {
//     // Arguments for Leap.vec3 are (out, a, b)
//     return [
//       Leap.vec3.subtract(positionVec3, positionVec3, this.frame.interactionBox.center),
//       Leap.vec3.divide(positionVec3, positionVec3, this.frame.interactionBox.size),
//       Leap.vec3.multiply(positionVec3, positionVec3, [window.innerWidth, window.innerHeight, 0])
//     ]
//   }
// });

controller.use('screenPosition', {
  positioning: 'absolute'
});

window.handHoldDemoCursor = $('.cursor');
window.handHoldDemoOutput = $('.output');

controller.use('screenPosition', { scale: 1 });

controller.on('connect', function() {
  console.log("Successfully connected.");
  setInterval(function() {
    var frame = controller.frame();
    var hand;
    if (hand = frame.pointables[0]) {

      handHoldDemoOutput.html(
        "[<br/>&nbsp;&nbsp;" + (hand.screenPosition()[0]) +
        "        <br/>&nbsp;&nbsp;" + (hand.screenPosition()[1]) +
        "        <br/>&nbsp;&nbsp;" + (hand.screenPosition()[2]) + "<br/>]"
        );

      return handHoldDemoCursor.css({
        left: hand.screenPosition()[0] + 'px',
        bottom: hand.screenPosition()[1] + 'px'
      });
    }
  }, 25);
});

controller.on('animationFrame', function(frame) {
    
});

controller.connect();
