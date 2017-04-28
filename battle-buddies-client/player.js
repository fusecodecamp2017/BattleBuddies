/**
 * Player
 */

class Player {
  constructor(params) {
    this.id = params.id;
    this.publicId = params.public_id;
    this.name = params.name;
    this.hp = params.hp;
    this.defense = params.defense;
    this.position = params.position;
  }
}

module.exports = Player;