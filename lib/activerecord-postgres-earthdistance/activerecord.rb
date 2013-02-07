# Extends AR to add earthdistance functionality.
require "activerecord-postgres-earthdistance/acts_as_geolocated"
module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      # Installs hstore by creating the Postgres extension
      # if it does not exist
      #
      def add_earthdistance_index table_name, options = {}
        execute "CREATE INDEX %s_earthdistance_ix ON %s USING gist (ll_to_earth(%s, %s));" %
          [table_name, table_name, (options[:lat] || 'lat'), (options[:lng] || 'lng')]
      end
    end
  end
end
