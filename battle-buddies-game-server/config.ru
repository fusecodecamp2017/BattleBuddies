require 'sinatra'
require "sinatra/reloader" if development?
require 'json'

require './app.rb'

run App