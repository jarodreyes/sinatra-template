require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'bcrypt'
require "sinatra/reloader" if development?
require 'dm-serializer'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-types'
require 'sinatra/flash'


#Configurations
configure do
  set :app_file, __FILE__
  set :sessions, true
end

configure :development do
  enable :logging, :dump_errors, :raise_errors 
end



require "./helpers"
require "./models"
require "./routes"


