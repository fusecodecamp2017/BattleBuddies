let Player = require('./player');

class Game {
  
  constructor() {
    this.players = {};
  }

  updateFromJson(response) {
    this.board = response.board;
    this.players = this.parseBoardForPlayers(response.board);
  }

  parseBoardForPlayers(board) {
    let playerHash = {};
    
    board.grid.forEach( (column, x) => {
      column.forEach( (cell, y) => {
        if (cell != null) {
          cell.position = { x : x, y : y };
          
          playerHash[cell.public_id] = new Player(cell);
        }
      })
    });

    return playerHash;
  }

  nearestPlayerTo(self) {
    let players = this.players;
    
    let dist = 10000;
    let closestPlayer;

    for(let pid in players) {
      let player = players[pid];

      if(pid !== self.publicId) {
        let newDist = this.getDistanceBetweenPlayers(self, player);

        if(dist > newDist) {
          dist = newDist;
          closestPlayer = player;
          console.log(`Target acquired: ${closestPlayer.name} ${dist} spaces away`);
        }
      }
    }

    return closestPlayer;
  }

  getDistanceBetweenPlayers(p1, p2) {
    let x1 = p1.position.x;
    let y1 = p1.position.y;
    let x2 = p2.position.x;
    let y2 = p2.position.y;

    return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
  }

  getDirectionTowardsPlayer(self, player) {
    let selfX = self.position.x,
        selfY = self.position.y, 
        pX = player.position.x, 
        pY = player.position.y;
    
    if (pX > selfX) {
      return "right";
    } else if (pY < selfY) {
      return "up";
    } else if (pY > selfY) {
      return "down";
    } else if (pX < selfX) {
      return "left";
    } 

    return "none";
  }
}

module.exports = Game