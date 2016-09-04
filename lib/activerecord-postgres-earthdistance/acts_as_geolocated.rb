module ActiveRecordPostgresEarthdistance
  module ActsAsGeolocated
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_geolocated(options = {})
        cattr_accessor :latitude_column, :longitude_column, :through_table
        self.latitude_column = options[:lat] || (column_names.include?("lat") ? "lat" : "latitude")
        self.longitude_column = options[:lng] || (column_names.include?("lng") ? "lng" : "longitude")
        self.through_table = options[:through]
      end

      def within_box(radius, lat, lng)
        earth_box = Arel::Nodes::NamedFunction.new('earth_box', [Utils.ll_to_earth_coords(lat, lng), Utils.quote_value(radius)])
        where Arel::Nodes::InfixOperation.new('<@', Utils.ll_to_earth_columns(through_table_klass), earth_box)
      end

      def within_radius(radius, lat, lng)
        earth_distance = Arel::Nodes::NamedFunction.new('earth_distance', [Utils.ll_to_earth_columns(through_table_klass), Utils.ll_to_earth_coords(lat, lng)])
        within_box(radius, lat, lng).where(Arel::Nodes::InfixOperation.new('<=', earth_distance, Utils.quote_value(radius)))
      end

      def order_by_distance(lat, lng, order = "ASC")
        earth_distance = Arel::Nodes::NamedFunction.new('earth_distance', [Utils.ll_to_earth_columns(through_table_klass), Utils.ll_to_earth_coords(lat, lng)])
        order("#{earth_distance.to_sql} #{order.to_s}")
      end

      private
      def through_table_klass
        through_table ? self.reflections[through_table.to_s].klass : self
      end
    end

    module Utils
      def self.ll_to_earth_columns(klass)
        Arel::Nodes::NamedFunction.new('ll_to_earth', [klass.arel_table[klass.latitude_column], klass.arel_table[klass.longitude_column]])
      end

      def self.ll_to_earth_coords lat, lng
        Arel::Nodes::NamedFunction.new('ll_to_earth', [quote_value(lat), quote_value(lng)])
      end

      def self.quote_value value
        if Arel::Nodes.respond_to?(:build_quoted) # for arel >= 6.0.0
          Arel::Nodes.build_quoted(value)
        else
          value
        end
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
