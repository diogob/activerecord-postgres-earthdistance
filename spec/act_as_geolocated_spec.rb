require 'spec_helper'

describe "ActiveRecord::Base.act_as_geolocated" do
  describe "#within_radius" do
    let(:test_data){ {lat: nil, lng: nil, radius: nil} }
    subject{ Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng]) }
    before(:all) do
      @place = Place.create!(:lat => -30.0277041, :lng => -51.2287346)
    end

    context "when query with null data" do
      it{ should == [] }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data){{lat: -30.0277041, lng: -51.2287346 , radius: 0}}
      it{ should == [@place] }
    end

    context "when query for place within radius" do
      let(:test_data){ {radius: 4000000, lat: -27.5969039, lng: -48.5494544} }
      it{ should == [@place] }
    end

    context "when query for place outside the radius" do
      let(:test_data){ {radius: 1000, lat: -27.5969039, lng: -48.5494544} }
    end
  end
end
