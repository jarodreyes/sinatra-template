require 'rubygems'
require 'sinatra'
require 'builder'

#TO DO Recupere les données du SMS envoyé
post '/' do
  builder do |xml|
    xml.instruct!
    xml.Response do 
      xml.Say("Bolo is awesome")
    end
  end
end 

get '/hello' do
  builder do |xml|
    xml.instruct!
    xml.Response do 
      xml.Say("Bolo from lordalexworks")
    end
  end
end 
