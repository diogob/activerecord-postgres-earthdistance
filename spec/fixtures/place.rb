class Place < ActiveRecord::Base
  acts_as_geolocated
  has_many :events
end
