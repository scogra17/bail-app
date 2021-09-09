require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "pry-byebug"
require "securerandom"

require_relative "database_persistence"
require_relative "event"
require_relative "attendee"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
  also_reload "event.rb"
end

after do
  @storage.disconnect
end

helpers do
  def generate_uuid
    SecureRandom.uuid
  end
end

before do
  @storage = DatabasePersistence.new(logger)
end

# load home page
get "/" do
  erb :home, layout: :layout
end

get "/event" do
  erb :new_event, layout: :layout
end

post "/event" do
  event_name = params[:event_name]
  event_location = params[:event_location]
  event_date = params[:event_date]
  event_time = params[:event_time]
  event_description = params[:event_description]
  event_key = generate_uuid

  event = Event.new(event_key,
    event_name,
    event_date,
    event_time,
    event_location,
    event_description
  )

  @storage.create_new_event(event)

  redirect "/event/#{event_key}"
end

get "/event/:key" do
  event_key = params[:key]
  @event = @storage.find_event(event_key)

  erb :event, layout: :layout
end

get "/event/:key/attend" do
  @event_key = params[:key]

  erb :new_attendee, layout: :layout
end

post "/event/:key/attend" do
  attendee_event_key = params[:key]
  attendee_name = params[:attendee_name]
  attendee_email = params[:attendee_email]
  attendee_bailcode = params[:attendee_bailcode]

  attendee = Attendee.new(
    attendee_name,
    attendee_email,
    attendee_bailcode,
    attendee_event_key
  )

  @storage.create_new_attendee(attendee)

  redirect "/event/#{attendee_event_key}"
end

