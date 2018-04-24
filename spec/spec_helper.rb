$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "rspec"
require "activerecord-postgres-earthdistance"
require "active_record"

RSpec.configure do |config|
  config.before(:suite) do
    # we create a test database if it does not exist
    # I do not use database users or password for the tests, using ident authentication instead
    begin
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        host: "localhost",
        username: "postgres",
        password: "postgres",
        port: 5432,
        database: "ar_pg_earthdistance_test"
      )
      ActiveRecord::Base.connection.execute %{
        SET client_min_messages TO warning;
        CREATE EXTENSION IF NOT EXISTS cube;
        CREATE EXTENSION IF NOT EXISTS earthdistance;
        DROP TABLE IF EXISTS places;
        DROP TABLE IF EXISTS events;
        DROP TABLE IF EXISTS jobs;
        CREATE TABLE places (id serial PRIMARY KEY, data text, lat float8, lng float8);
        CREATE TABLE events (
          id serial PRIMARY KEY,
          event_id integer,
          place_id integer,
          data text,
          lat float8,
          lng float8
        );
        CREATE TABLE jobs (id serial PRIMARY KEY, event_id integer);
}
    rescue StandardError => e
      puts "Exception: #{e}"
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        host: "localhost",
        username: "postgres",
        password: "postgres",
        port: 5432,
        database: "postgres"
      )
      ActiveRecord::Base.connection.execute "CREATE DATABASE ar_pg_earthdistance_test"
      retry
    end

    # Load models used in spec
    require "fixtures/place"
    require "fixtures/event"
    require "fixtures/job"
  end
end
