require "pg"
require "pry-byebug"

require_relative "event"
require_relative "attendee"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "bail-app")
    end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def create_new_event(event)
    sql = <<~SQL
      INSERT INTO events (pkey, name, start_date, start_time, location, description)
      VALUES ($1, $2, $3, $4, $5, $6)
    SQL
    query(sql,
      event.key,
      event.name,
      event.date,
      event.time,
      event.location,
      event.description
    )
  end

  def find_event(key)
    sql = <<~SQL
      SELECT * FROM events WHERE pkey = $1
    SQL

    result = query(sql, key)

    return nil if result.ntuples == 0

    tuple = result.first
    tuple_to_event(tuple)
  end

  def create_new_attendee(attendee)
    sql = <<~SQL
      INSERT INTO attendees (display_name, email, bailcode, event_id)
      VALUES ($1, $2, $3, $4)
    SQL

    query(sql,
      attendee.name,
      attendee.email,
      attendee.bailcode,
      attendee.event_key
    )
  end

  def find_event_attendees(event_key)
    sql = <<~SQL
      SELECT * FROM attendees
      WHERE event_id = $1
    SQL

    result = query(sql, event_key)

    return nil if result.ntuples == 0

    result.map do |tuple|
      tuple_to_attendee(tuple)
    end
  end

  def find_event_attendee(attendee)
    sql = <<~SQL
      SELECT * FROM attendees
      WHERE event_id = $1
        AND email = $2
    SQL

    result = query(sql, attendee.event_key, attendee.email)

    return nil if result.ntuples == 0

    tuple = result.first
    tuple_to_attendee(tuple)
  end

  def update_attendee(attendee)
    sql = <<~SQL
      UPDATE attendees
      SET bailed = true
      WHERE pkey = $1
    SQL

    query(sql, attendee.key)
  end

  def update_event(event)
    sql = <<~SQL
      UPDATE events
      SET canceled = true
      WHERE pkey = $1
    SQL

    query(sql, event.key)
  end

  private

  def tuple_to_event(tuple)
    event_key = tuple["pkey"]
    event_name = tuple["name"]
    event_location = tuple["location"]
    event_date = tuple["start_date"]
    event_time = tuple["start_time"]
    event_description = tuple["description"]

    Event.new(event_key,
      event_name,
      event_date,
      event_time,
      event_location,
      event_description
    )
  end

  def tuple_to_attendee(tuple)
    attendee_key = tuple["pkey"]
    attendee_name = tuple["display_name"]
    attendee_email = tuple["email"]
    attendee_bailcode = tuple["bailcode"]
    attendee_bailed = tuple["bailed"] == "t"
    attendee_event_key = tuple["event_id"]

    Attendee.new(
      attendee_key,
      attendee_name,
      attendee_email,
      attendee_bailcode,
      attendee_bailed,
      attendee_key
    )
  end

  # def create_new_list(list_name)
  #   sql = "INSERT INTO lists (name) VALUES ($1)"
  #   result = query(sql, list_name)
  # end

  # def delete_list(id)
  #   query("DELETE FROM todos WHERE list_id = $1", id)
  #   query("DELETE FROM lists WHERE id = $1", id)
  # end

  # def update_list_name(id, new_name)
  #   sql = "UPDATE lists SET name = $1 WHERE id = $2"
  #   query(sql, new_name, id)
  # end

  # def create_new_todo(list_id, todo_name)
  #   sql = "INSERT INTO todos (name, list_id) VALUES ($1, $2)"
  #   query(sql, todo_name, list_id)
  # end

  # def delete_todo_from_list(list_id, todo_id)
  #   sql = "DELETE FROM todos WHERE list_id = $1 AND id = $2"
  #   query(sql, list_id, todo_id)
  # end

  # def update_todo_status(list_id, todo_id, new_status)
  #   sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
  #   query(sql, new_status, todo_id, list_id)
  # end

  # def mark_all_todos_as_completed(list_id)
  #   sql = "UPDATE todos SET completed = true WHERE list_id = $1"
  #   query(sql, list_id)
  # end

  # def find_todos_for_list(list_id)
  #   sql = "SELECT * FROM todos WHERE list_id = $1"
  #   result = query(sql, list_id)
  #   result.map do |tuple|
  #     {id: tuple["id"].to_i, name: tuple["name"], completed: tuple["completed"] == "t"}
  #   end
  # end

  # private

  # def tuple_to_list_hash(tuple)
  #   { id: tuple["id"].to_i,
  #     name: tuple["name"],
  #     todos_count: tuple["todos_count"].to_i,
  #     todos_remaining_count: tuple["todos_remaining_count"].to_i }
  # end
end
