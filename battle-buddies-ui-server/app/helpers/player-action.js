import Ember from 'ember';

let {
  get,
  isNone,
  isEmpty
  } = Ember;

export function playerAction(params/*, hash*/) {
  let player = params[0];
  if(isNone(player)){ return ""; }

  let turns = get(player, "turns");
  if(isEmpty(turns)) { return ""; }

  let lastTurn = turns[get(turns, "length") - 1];
  if(isNone(lastTurn)) { return ""; }

  let events = get(lastTurn, "events");
  if(isEmpty(events)) { return ""; }

  let firstEvent = get(events, "firstObject");
  if(isNone(firstEvent)) { return ""; }

  let description = get(firstEvent, "description");

  return description;
}

export default Ember.Helper.helper(playerAction);
