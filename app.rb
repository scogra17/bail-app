require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
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
  also_reload "attendee.rb"
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
  attendees = @storage.find_event_attendees(event_key)
  @event.attendees = attendees
  @event.cancel! if @event.all_attendees_bailed?
  @storage.update_event(@event)

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
    nil,
    attendee_name,
    attendee_email,
    attendee_bailcode,
    nil,
    attendee_event_key
  )

  @storage.create_new_attendee(attendee)

  redirect "/event/#{attendee_event_key}"
end

get "/event/:key/bail" do
  @event_key = params[:key]

  erb :bail, layout: :layout
end

post "/event/:key/bail" do
  @event_key = params[:key]
  attendee_email = params[:attendee_email]
  attendee_bailcode = params[:attendee_bailcode]
  proposed_attendee = Attendee.new(
    nil,
    nil,
    attendee_email,
    attendee_bailcode,
    nil,
    @event_key
  )

  # 1) pull information for given event and email
  actual_attendee = @storage.find_event_attendee(proposed_attendee)
  # 2) compare bailcodes
  if !actual_attendee
    erb :bail, layout: :layout
  elsif actual_attendee.bailcode == proposed_attendee.bailcode
    actual_attendee.bail!
    @storage.update_attendee(actual_attendee)
    redirect "/event/#{@event_key}"
  else
    erb :bail, layout: :layout
  end
end
