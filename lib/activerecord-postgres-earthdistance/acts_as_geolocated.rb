module ActiveRecordPostgresEarthdistance
  module ActsAsGeolocated
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_geolocated(options = {})
        if table_exists?
          cattr_accessor :latitude_column, :longitude_column
          self.latitude_column = options[:lat] || (column_names.include?("lat") ? "lat" : "latitude")
          self.longitude_column = options[:lng] || (column_names.include?("lng") ? "lng" : "longitude")
        end
      end

      def within_box(radius, lat, lng)
        earth_box = Arel::Nodes::NamedFunction.new('earth_box', [ll_to_earth_coords(lat, lng), radius])
        where Arel::Nodes::InfixOperation.new('<@', ll_to_earth_columns, earth_box)
      end

      def within_radius(radius, lat, lng)
        earth_distance = Arel::Nodes::NamedFunction.new('earth_distance', [ll_to_earth_columns, ll_to_earth_coords(lat, lng)])
        within_box(radius, lat, lng).where(Arel::Nodes::InfixOperation.new('<=', earth_distance, radius))
      end

      def order_by_distance(lat, lng, order = "ASC")
        earth_distance = Arel::Nodes::NamedFunction.new('earth_distance', [ll_to_earth_columns, ll_to_earth_coords(lat, lng)])
        order("#{earth_distance.to_sql} #{order.to_s}")
      end

      protected
      def ll_to_earth_columns
        Arel::Nodes::NamedFunction.new('ll_to_earth', [arel_table[self.latitude_column], arel_table[self.longitude_column]])
      end

      def ll_to_earth_coords lat, lng
        Arel::Nodes::NamedFunction.new('ll_to_earth', [lat, lng])
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
