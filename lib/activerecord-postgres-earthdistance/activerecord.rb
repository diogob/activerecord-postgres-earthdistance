# Extends AR to add earthdistance functionality.
require "activerecord-postgres-earthdistance/acts_as_geolocated"
module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      # Installs hstore by creating the Postgres extension
      # if it does not exist
      #
      def add_earthdistance_index
        execute "CREATE EXTENSION IF NOT EXISTS hstore"
      end
    end
  end
end
