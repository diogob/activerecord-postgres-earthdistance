# Extends AR to add Hstore functionality.
module ActiveRecord

  # Adds methods for deleting keys in your hstore columns
  class Base

    # Searches for record within a radius
    def self.within_radius radius, lat, lng
      where(["ll_to_earth(lat, lng) <@ earth_box(ll_to_earth(?, ?), ?)", lat, lng, radius])
    end

  end

end
