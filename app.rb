require_relative 'config/environment'
require "pry"
class Application < Sinatra::Base
  # Write your code here!

   get '/' do
      erb :index
   end

   post '/greet' do
      erb :greet
   end

end