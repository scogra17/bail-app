require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "sinatra/reloader"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
end

after do
  @storage.disconnect
end

# load home page
get "/" do
  "Hello world"
end

