class Job < ActiveRecord::Base
  acts_as_geolocated through: :event
  belongs_to :event
end
