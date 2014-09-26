module ActiveRecordPostgresEarthdistance
  module ActsAsGeolocated
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_geolocated(options = {})
        if table_exists?
          cattr_accessor :latitude_column, :longitude_column
          self.latitude_column = options[:lat] || (column_names.include?("lat") ? "lat" : "latitude")
          self.longitude_column = options[:lng] || (column_names.include?("lng") ? "lng" : "longitude")
        end
      end

      def within_radius radius, lat, lng
        where(["ll_to_earth(#{self.latitude_column}, #{self.longitude_column}) <@ earth_box(ll_to_earth(?, ?), ?)" +
               "AND earth_distance(ll_to_earth(#{self.latitude_column}, #{self.longitude_column}), ll_to_earth(?, ?)) <= ?",
               lat, lng, radius, lat, lng, radius])
      end

      def order_by_distance lat, lng, order= "ASC"
        order("earth_distance(ll_to_earth(#{self.latitude_column}, #{self.longitude_column}), ll_to_earth(#{lat}, #{lng})) #{order}")
      end
    end
  end

  module QueryMethods
    def selecting_distance_from lat, lng, name="distance", include_default_columns=true
      clone.tap do |relation|
        values = []
        values << relation.arel_table[Arel.star] if relation.select_values.empty? && include_default_columns
        values << "earth_distance(ll_to_earth(#{self.latitude_column}, #{self.longitude_column}), ll_to_earth(#{lat}, #{lng})) as #{name}"
        relation.select_values = values
      end
    end
  end

end

ActiveRecord::Base.send :include, ActiveRecordPostgresEarthdistance::ActsAsGeolocated
ActiveRecord::Relation.send :include, ActiveRecordPostgresEarthdistance::QueryMethods
