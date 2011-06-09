# Extends AR to add earthdistance functionality.
module ActiveRecord
  class Base
    def self.acts_as_geolocated(options = {}, distances = {})
      @@latitude_column = options[:lat]
      @@longitude_column = options[:lng]
      @@latitude_column = (column_names.include?("lat") ? "lat" : "latitude") unless @@latitude_column
      @@longitude_column = (column_names.include?("lng") ? "lng" : "longitude") unless @@longitude_column

      def self.within_radius radius, lat, lng, unit = :meters
        where(["ll_to_earth(#{@@latitude_column}, #{@@longitude_column}) <@ earth_box(ll_to_earth(?, ?), ?)
               AND earth_distance(ll_to_earth(#{@@latitude_column}, #{@@longitude_column}), ll_to_earth(?, ?)) <= ?", 
               radius, lat, lng, radius, lat, lng])
      end
    end
  end
end
