import Ember from 'ember';

let {
  Component,
  computed,
  inject,
  get,
  set,
  Handlebars,
  isPresent,
  run,
  isEmpty
  } = Ember;

export default Component.extend({

  classNames: ["application"],

  api: inject.service("application"),

  applicationTitle: "Multi-Player Battle Game",
  subTitle: "Fuse Code Camp 2017",

  game: null,
  grid: computed.alias("game.board.grid"),

  requestCount: 0,
  playerCount: computed("requestCount", function(){
    let game = get(this, "game");
    if(isEmpty(game)){
      return 0;
    }
    return get(game, "players.length");
  }),

  deceasedCount: computed("requestCount", function(){
    let game = get(this, "game");
    if(isEmpty(game)){
      return 0;
    }
    return get(game, "deceased.length");
  }),

  gameStatuses: {NS: "Not Started", ST: "Started", E: "Error", L: "Loading", U: "Unknown"},
  gameStatus: "L",
  gameStatusDisplay: computed("gameStatus", function(){
    let statusText = get(get(this, "gameStatuses"), get(this, "gameStatus"));
    if(isEmpty(statusText)){
      statusText = get(get(this, "gameStatuses"), "U");
    }
    return statusText;
  }),

  isLoading: computed.equal("gameStatus", "L"),
  isNotStarted: computed.equal("gameStatus", "NS"),
  isStarted: computed.equal("gameStatus", "ST"),
  isError: computed.equal("gameStatus", "E"),

  errorMessage: "",

  gameState: Ember.observer("requestCount", function(){
    run.once(() => {
        get(this, "api").getGameState().then(results => {
          this.gameSuccess(get(results, "content"));
        }).catch(error => {
          this.gameError(error);
        });
    });
  }).on("init"),

  gameSuccess(results){
    let game = get(results, "game");
    set(this, "game", game);
    set(this, "gameStatus", "ST");

    run.later(() => {
      this.incrementProperty("requestCount");
    });
  },

  gameError(error){
    console.error(error);
    set(this, "gameStatus", "E");

    let errorMessage = "Default Error";
    if(isPresent(get(error, "responseText"))){
      errorMessage = get(error, "responseText");

      if(isPresent(errorMessage)){
        try {
          let json = JSON.parse(errorMessage);

          if (isPresent(get(json, "content"))) {
            errorMessage = get(json, "content");
          }
        } catch(e){
          errorMessage = "Default Error";
        }
      }
    }

    set(this, "errorMessage", errorMessage);

    run.later(this, () => {
       this.incrementProperty("requestCount");
    }, 5000);
  },

  width: computed("grid.[]", function(){
    return get(this, "grid.length");
  }),
  height: computed("grid.[]", function(){
    return get(this, "grid.firstObject.length");
  }),

  blockCSS: computed("width", "height", function(){
    let vw = 90 / get(this, "width");
    let vh = 90 / get(this, "height");

    return new Handlebars.SafeString(`min-width: ${vw}vw; max-width: ${vw}vw; min-height: ${vh}vh; max-height: ${vh}vh;`);
  })

});
