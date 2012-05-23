require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'dm-serializer'
#require 'dm-core'
#require 'dm-validations'
#require 'dm-timestamps'
#require 'dm-migrations'
#require 'dm-types'
#require 'sinatra/flash'
#require 'sinatra/authorization'

#####
##CONFIGURATIONs
####
configure do
   set :app_file, __FILE__
 end

 configure :development do
   enable :logging, :dump_errors, :raise_errors
 end

 configure :qa do
   enable :logging, :dump_errors, :raise_errors
 end

 configure :production do
   set :raise_errors, false #false will show nicer error page
   set :show_exceptions, false #true will ignore raise_errors and display backtrace in browser
 end

#####
##DATABASES
####

#DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

#class User
#   include DataMapper::Resource  
#   property :id,         Serial
#   property :uid,        String  , :unique  => true
#   property :created_at, DateTime , :default => DateTime.now
   
#   has n, :mailings
#end

#DataMapper.finalize
#DataMapper.auto_upgrade!

#####
## Helpers
####

helpers do
  
end

#####
## Routes
####

get '/' do
  erb :index
end
