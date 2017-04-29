class TurnManager {

  calculateTurn(player, game) {
    let pid = player.id;

    let enemy = game.nearestPlayerTo(player);

    let direction = "none";

    if(enemy) {
      direction = game.getDirectionTowardsPlayer(player, enemy);
    }

    let params = {
      player_id: pid,
      direction: direction,
      action: "move"
    }

    if(enemy && game.getDistanceBetweenPlayers(player, enemy) === 1) {
      params.action = "attack";
    }

    console.log(`${params.action} ${params.direction}`);

    return params ;
  }

}

module.exports = TurnManager