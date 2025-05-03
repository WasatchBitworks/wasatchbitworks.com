require "sinatra"
require "sinatra/content_for"
require 'tilt/erubi'
require "date"

#require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  #also_reload "database_persistence.rb"
end

helpers do
  def help
    puts "help"
  end
end

before do
  #@storage = DatabasePersistence.new(logger)
end

after do
  #@storage.disconnect
end

get "/" do
  redirect "/home"
end

get "/home" do
  

  erb :home, layout: :layout
end

get "/services" do
  
  erb :services, layout: :layout
end

get "/about" do
  
  erb :about, layout: :layout
end

get "/contact" do


  erb :contact, layout: :layout
end