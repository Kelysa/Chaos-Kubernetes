const Snake = require('./snake.js');
const settings = require('./settings.js');

var socketList = [];
var snake;

var initServer = function(io) {
  // player connection
  io.on('connection', this.connection);
  // initialize board on server start and add update listener to snake class
  snake = new Snake(settings.boardSize);
  snake.setListener(this.gameEvent);
}

var connection = function(socket) {
  // store player sockets
  socketList.push(socket);

  // initialize player
  socket.on('start', function(playerName) {
    snake.addPlayer(playerName, socket);
  });
  // remove player on disconnect
  socket.on('disconnect', function() {
    console.log('A player has disconnected');
    snake.removePlayer(socket);
  });
  // capture movement keystrokes
  socket.on('keystroke', function(keyCode) {
    snake.keyStroke(keyCode, socket);
  });
}

var gameEvent = function(event, data) {
  // emit updated data
  if (event == 'update' && typeof socketList !== 'undefined') {
    for (var i = 0; i < socketList.length; i++) {
      socketList[i].emit('update', data);
    }
  }
}

module.exports = {initServer, gameEvent, connection, socketList, snake};
