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
require 'koala'
require 'Pony'

#Configurations
configure do
  set :app_file, __FILE__
  set :sessions, true
end

configure :development do
  enable :logging, :dump_errors, :raise_errors 
end

# Clear out sessions


#use OmniAuth::Strategies::Facebook, '367406863305263', '85db8b89b88b408e9a04dcf4021e9c95'
FACEBOOK_SCOPE = 'email'

require "#{File.dirname(__FILE__)}/helpers.rb"
require "#{File.dirname(__FILE__)}/models.rb"
require "#{File.dirname(__FILE__)}/routes.rb"



