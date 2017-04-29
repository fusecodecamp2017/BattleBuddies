/**
 * RequestService
 */

// Imports
let request = require('request-promise-native');

class RequestService {
  constructor(url) {
    this.url = url;
    this.timeout = 600000;
  }

  sendGET(endpoint) {
    let params = {
      method: 'GET',
      uri: `${this.url}/${endpoint}`,
      timeout: this.timeout
    };

    return request(params).then(
      (response) => {
        return this.parseResponse(response);
      },

      (error) => {
        return this.parseResponse(error.response.body);
      });
  }

  sendPOST(endpoint, data) {
    let params = {
      method: 'POST',
      uri: `${this.url}/${endpoint}`,
      timeout: this.timeout,
      form: data
    }

    return request(params).then(
      (response) => {
        return this.parseResponse(response);
      },

      (error) => {
        return this.parseResponse(error.response.body);
      });
  }

  parseResponse(response) {
    let json = JSON.parse(response);

    if(!json.success) {
      throw json.content.message || json.content;
    }

    return json.content;
  }


  getHomepage() {
    return this.sendGET('').then(response => {
      return response.message;
    });
  }

  registerPlayer(name, hp = 4, defense = 4, damage = 1) {
    let params = { 
      name: name,
      hp:hp,
      defense: defense,
      damage: damage
    };

    return this.sendPOST('player', params);
  }

  makeTurn(turn) {
    return this.sendPOST('game/turn', turn);
  }
}

module.exports = RequestService;