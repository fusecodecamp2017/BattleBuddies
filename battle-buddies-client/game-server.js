/**
 * GameServer
 */

// Imports
let RequestService = require('./request-service');
let Player = require('./player');

class GameServer {
  constructor(url) {
    this.url = url;
    this.RS = new RequestService(url);
  }

  start() {
    console.log("Starting server!");
    return this.RS.registerPlayer("neo").then(playerJson => {
      this.player = new Player(playerJson);
    });
  }
}

module.exports = GameServer;