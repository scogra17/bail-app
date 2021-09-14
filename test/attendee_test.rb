require 'minitest/autorun'
require_relative '../attendee'

class AttendeeTest < Minitest::Test
  def setup
    @attendee = Attendee.new(
      "test_key",
      "test_name",
      "test_email@gmail.com",
      "test_bailcode",
      false,
      "test_event_key")
  end

  def test_bail!
    assert_equal false, @attendee.bailed
    @attendee.bail!
    assert_equal true, @attendee.bailed
  end

  def test_bailed?
    assert_equal false, @attendee.bailed?
  end
end
