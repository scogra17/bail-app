class Attendee
  attr_reader :name, :email, :bailcode, :event_key

  def initialize(name, email, bailcode, event_key)
    @name = name
    @email = email
    @bailcode = bailcode
    @event_key = event_key
  end
end