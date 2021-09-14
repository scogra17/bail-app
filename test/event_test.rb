require 'minitest/autorun'
require_relative '../event'
require_relative '../attendee'

class EventTest < Minitest::Test
  def setup
    @event = Event.new(
      "test_key",
      "test_name",
      "test_date",
      "test_time",
      "test_location",
      "test_description")

    @attendee = Attendee.new(
      "test_key",
      "test_name",
      "test_email@gmail.com",
      "test_bailcode",
      false,
      "test_event_key")

    @event.attendees = [@attendee]
  end

  def test_all_attendees_bailed?
    assert_equal false, @event.all_attendees_bailed?
    @attendee.bail!
    assert_equal true, @event.all_attendees_bailed?
  end
end
