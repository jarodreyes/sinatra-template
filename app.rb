require 'rubygems'
require 'sinatra'
require 'builder'

post '/' do
  builder do |xml|
    xml.instruct!
    xml.Response do 
      xml.Say("Bolo is awesome")
    end
  end
end 