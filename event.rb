class Event
  attr_reader :key, :name, :date, :time, :location, :description

  def initialize(key, name, date, time, location, description)
    @key = key
    @name = name
    @date = date
    @time = time
    @location = location
    @description = description
  end
end
