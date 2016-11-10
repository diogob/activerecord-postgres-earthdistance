# Extends AR to add earthdistance functionality.
require "activerecord-postgres-earthdistance/acts_as_geolocated"
module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      def add_earthdistance_index(table_name, options = {})
        execute("CREATE INDEX %s_earthdistance_ix ON %s USING gist (ll_to_earth(%s, %s));" % [table_name, table_name, (options[:lat] || "lat"), (options[:lng] || "lng")])
      end

      def remove_earthdistance_index(table_name)
        execute("DROP INDEX %s_earthdistance_ix;" % [table_name])
      end
    end
  end
end
