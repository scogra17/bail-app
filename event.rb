class Event
  attr_reader :key, :name, :date, :time, :location, :description, :canceled
  attr_accessor :attendees

  def initialize(key, name, date, time, location, description)
    @key = key
    @name = name
    @date = date
    @time = time
    @location = location
    @description = description
    @canceled = false
    @attendees = nil
  end

  def all_attendees_bailed?
    !!(attendees.all?(&:bailed?) if attendees)
  end

  def cancel!
    self.canceled = true
  end

  def canceled?
    canceled
  end

  private

  attr_writer :canceled
end
