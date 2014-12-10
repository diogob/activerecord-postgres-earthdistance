class Event < ActiveRecord::Base
  acts_as_geolocated
  belongs_to :place
  has_many :events
end
