class Attendee
  attr_reader :key, :name, :email, :bailcode, :bailed, :event_key

  def initialize(key, name, email, bailcode, bailed=false, event_key)
    @key = key
    @name = name
    @email = email
    @bailcode = bailcode
    @bailed = bailed
    @event_key = event_key
  end

  def bail!
    self.bailed = true
  end

  def bailed?
    bailed
  end

  private

  attr_writer :bailed
end