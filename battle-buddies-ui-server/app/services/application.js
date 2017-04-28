import Ember from 'ember';

let {
  Service,
  get,
  $,
  RSVP,
  isPresent
  } = Ember;

export default Service.extend({

  host: "http://localhost:8282/",

  getGameState(){
    return this.getJson("game");
  },

  buildUrl(path){
    return get(this, "host") + path;
  },

  getJson(path) {
    let requestType = "GET";
    let url = this.buildUrl(path, requestType);
    return this.ajax(requestType, url);
  },

  ajax: function (requestType, url, data) {

    return new RSVP.Promise((resolve, reject) => {

      let options = {
        url: url,
        type: requestType,
        dataType: 'json'
      };

      if (isPresent(data) && requestType !== 'GET') {
        options.contentType = 'application/json; charset=utf-8';
        options.data = JSON.stringify(data);
      }

      options.success = function (results) {
        resolve(results);
      };

      options.error = function (error) {
        reject(error);
      };

      $.ajax(options);

    }, "Fuse: JsonREST " + requestType + " for url " + url);

  }


});
