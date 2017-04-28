/**
 * index.js
 */

// Imports
let GameServer = require('./game-server');


// Run code
let url = "http://localhost:8282";
let server = new GameServer(url);

server.start().catch(error => {
  console.error(error.toString());
});