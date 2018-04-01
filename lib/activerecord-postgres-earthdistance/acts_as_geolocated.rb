module ActiveRecordPostgresEarthdistance
  module ActsAsGeolocated
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_geolocated(options = {})
        if table_exists?
          cattr_accessor :latitude_column, :longitude_column, :through_table
          self.latitude_column = options[:lat] || (column_names.include?("lat") ? "lat" : "latitude")
          self.longitude_column = options[:lng] ||
                                  (column_names.include?("lng") ? "lng" : "longitude")
          self.through_table = options[:through]
        else
          puts "[WARNING] table #{table_name} doesn't exist, acts_as_geolocated won't work. Skip this warning if you are running db migration"
        end
      rescue ActiveRecord::NoDatabaseError
      end

      def within_box(radius, lat, lng)
        earth_box = Arel::Nodes::NamedFunction.new(
          "earth_box",
          [Utils.ll_to_earth_coords(lat, lng), Utils.quote_value(radius)]
        )
        joins(through_table)
          .where(
            Arel::Nodes::InfixOperation.new(
              "<@",
              Utils.ll_to_earth_columns(through_table_klass),
              earth_box
            )
          )
      end

      def within_radius(radius, lat, lng)
        earth_distance = Utils.earth_distance(through_table_klass, lat, lng)
        within_box(radius, lat, lng)
          .where(Arel::Nodes::InfixOperation.new("<=", earth_distance, Utils.quote_value(radius)))
      end

      def order_by_distance(lat, lng, order = "ASC")
        earth_distance = Utils.earth_distance(through_table_klass, lat, lng)
        joins(through_table).order("#{earth_distance.to_sql} #{order}")
      end

      def through_table_klass
        if through_table.present?
          reflections[through_table.to_s].klass
        else
          self
        end
      end
    end
  end

  module Utils
    def self.earth_distance(through_table_klass, lat, lng, aliaz = nil)
      Arel::Nodes::NamedFunction.new(
        "earth_distance",
        [
          ll_to_earth_columns(through_table_klass),
          ll_to_earth_coords(lat, lng)
        ],
        aliaz
      )
    end

    def self.ll_to_earth_columns(klass)
      Arel::Nodes::NamedFunction.new(
        "ll_to_earth",
        [klass.arel_table[klass.latitude_column], klass.arel_table[klass.longitude_column]]
      )
    end

    def self.ll_to_earth_coords(lat, lng)
      Arel::Nodes::NamedFunction.new("ll_to_earth", [quote_value(lat), quote_value(lng)])
    end

    def self.quote_value(value)
      if Arel::Nodes.respond_to?(:build_quoted) # for arel >= 6.0.0
        Arel::Nodes.build_quoted(value)
      else
        value
      end
    end
  end

  module QueryMethods
    def selecting_distance_from(lat, lng, name = "distance", include_default_columns = true)
      clone.tap do |relation|
        relation.joins!(through_table)
        values = []
        if relation.select_values.empty? && include_default_columns
          values << relation.arel_table[Arel.star]
        end
        values << Utils.earth_distance(through_table_klass, lat, lng, name)

        relation.select_values = values
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecordPostgresEarthdistance::ActsAsGeolocated
ActiveRecord::Relation.send :include, ActiveRecordPostgresEarthdistance::QueryMethods
