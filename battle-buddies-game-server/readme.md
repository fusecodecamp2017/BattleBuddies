***Battle Buddies: Server Edition***

This is the server for Battle Buddies, a full-day course made for Fuse Code Camp 2017 targeted at students grades 6-12.
Currently, it is written in Ruby with Sinatra and thin.

**To install**

Make sure you have RubyGems installed: https://rubygems.org/pages/download

You should also have bundler installed: ```gem install bundler```

Then,

    1. Run ```bundle install```
    2. Create a config.yml using the following template:

      ```
      ---
       environment: development
       address: 127.0.0.1
       user: user.name
       group: staff
       port: 8282
       pid: ./thin.pid
       rackup: ./config.ru
       log: ./thin.log
       max_conns: 1024
       timeout: 30
       max_persistent_conns: 512
       daemonize: false
       threaded: true
      ```
    3. Replace "user.name" in config.yml with your system username
    4. run thin start -R config.ru -C config.yml
    5. Pray that it works

**To run**

Run ```thin start -R config.ru -C config.yml``` in your terminal. This should run the server on port 8282 of your localhost.

**API**

get / 
  
    Home page

get /game
  
    Returns the board at the end of a turn

post /game
    Creates a game

post /game/start
  
    Starts the game

post /game/turn
  
    Posts a turn and returns the game state at the end of a turn

    Takes the following body: 

        ```
        {
          action: [move, attack, block, wait], //wait, attack, and block not implemented yet
          direction : [up, down, left, right, none]
          player_id : [player_id]
        }
        ```

post /player
  
    Creates a player and returns the generated id


Workflow:

    Create game > Create player > Start game       > Submit turns

    post /game  > post /player  > post /game/start > post /game/turn
