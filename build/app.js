const express = require('express');
const http = require('http');
const path = require('path');
const socketIO = require('socket.io');
const app = express();
const server = http.createServer(app);
const io = socketIO(server);

app.use(express.static(path.join(__dirname, 'public')));

var socket_server = require('./server/server.js');

socket_server.initServer(io);

server.listen(process.env.PORT || 3000, function() {
  console.log('Listening');
});
