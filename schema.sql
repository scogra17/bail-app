CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE events (
  pkey UUID UNIQUE NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  location text NOT NULL,
  start_date date DEFAULT CURRENT_DATE,
  start_time time NOT NULL DEFAULT '00:00:00',
  created_at timestamp DEFAULT NOW()
);

ALTER TABLE events
  ADD CHECK (LENGTH(TRIM(FROM name)) > 0),
  ADD CHECK (LENGTH(TRIM(FROM description)) > 0),
  ADD CHECK (LENGTH(TRIM(FROM location)) > 0);

CREATE TABLE attendees (
  pkey UUID NOT NULL DEFAULT uuid_generate_v1(),
  display_name text NOT NULL,
  email text NOT NULL,
  bailed boolean NOT NULL DEFAULT false,
  bailcode text NOT NULL,
  event_id UUID NOT NULL REFERENCES events (pkey)
);

ALTER TABLE attendees
  ADD CHECK (LENGTH(TRIM(FROM display_name)) > 0),
  ADD CHECK (LENGTH(TRIM(FROM email)) > 0),
  ADD CHECK (email SIMILAR TO '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
  ADD CHECK (LENGTH(TRIM(FROM mobile)) > 0),
  ADD CHECK (LENGTH(TRIM(FROM bailcode)) > 0);
