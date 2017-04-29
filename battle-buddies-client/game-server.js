/**
 * GameServer
 */

// Imports
let RequestService = require('./request-service');
let TurnManager = require('./turn-manager');
let Player = require('./player');
let Game = require('./game');

class GameServer {
  constructor(url) {
    this.url = url;
    this.RS = new RequestService(url);

    this.turnManager = new TurnManager();
    this.game = new Game();
  }

  start() {
    console.log("Starting server!");
    return this.RS.registerPlayer("Attack Bot", 4, 4, 1).then(playerJson => {
      this.player = new Player(playerJson);
      console.log(`Player registered! Name: ${this.player.name}`)
    }).then(() => {
      return this.makeTurn();
    });
  }

  makeTurn() {
    let player = this.player;
    let game = this.game;
    let params = this.turnManager.calculateTurn(player, game);

    return this.RS.makeTurn(params).then(response => {
      
      game.updateFromJson(response.game);
      player.updatePlayer(response.game.player);

      if(player.isDead()) {
        return this.gameOver();
      }
      return this.makeTurn();
    })
  }

  gameOver() {
    console.log("Game over! You are dead.");
  }
}

module.exports = GameServer;