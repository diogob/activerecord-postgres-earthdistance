require 'spec_helper'

describe "ActiveRecord::Base.act_as_geolocated" do
  describe 'ActiveRecord::Base' do
    context "when using .where with a model instance as a placeholder" do
      let(:place) { Place.create! }
      subject { Place.where('id = ?', place).first }
      after { place.destroy! }

      it { should == place }
    end
  end

  describe "#within_box" do
    let(:test_data) { { lat: nil, lng: nil, radius: nil } }

    subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

    before(:all) { @place = Place.create!(:lat => -30.0277041, :lng => -51.2287346) }
    after(:all) { @place.destroy }

    context "when query with null data" do
      it { should be_empty }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data) { { lat: -30.0277041, lng: -51.2287346 , radius: 0 } }

      it { should == [@place] }
    end

    context "when query for place within the box" do
      let(:test_data) { { radius: 4000000, lat: -27.5969039, lng: -48.5494544 } }

      it { should == [@place] }
    end

    context "when query for place within the box, but outside the radius" do
      let(:test_data) { { radius: 300000, lat: -27.5969039, lng: -48.5494544 } }

      it "the place shouldn't be within the radius" do
        Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).should be_empty
      end

      it { should == [@place] }
    end

    context "when query for place outside the box" do
      let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }
      it { should be_empty }
    end

    context "when joining tables that are also geoloacted" do
      let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }

      subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

      it "should work with objects having columns with the same name" do
        expect { Place.joins(:events).within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a }.to_not raise_error

      end

      it "should work with nested associations" do
        expect { Event.joins(:events).within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a }.to_not raise_error
      end
    end
  end

  describe "#within_radius" do
    let(:test_data){ {lat: nil, lng: nil, radius: nil} }
    subject{ Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng]) }
    before(:all) do
      @place = Place.create!(:lat => -30.0277041, :lng => -51.2287346)
    end

    after(:all) do
      @place.destroy
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
      it{ should == [] }
    end

    context "uses lat and long of through table" do

      subject{ Job.joins(:event).within_radius(test_data[:radius], test_data[:lat], test_data[:lng]) }

      before(:all) do
        @event = Event.create!(:lat => -30.0277041, :lng => -51.2287346)
        @job = Job.create!(event: @event)
      end

      after(:all) do
        @event.destroy
        @job.destroy
      end

      context "when query with null data" do
        it{ should == [] }
      end

      context "when query for the exact same point with radius 0" do
        let(:test_data){{lat: -30.0277041, lng: -51.2287346 , radius: 0}}
        it{ should == [@job] }
      end

      context "when query for place within radius" do
        let(:test_data){ {radius: 4000000, lat: -27.5969039, lng: -48.5494544} }
        it{ should == [@job] }
      end

      context "when query for place outside the radius" do
        let(:test_data){ {radius: 1000, lat: -27.5969039, lng: -48.5494544} }
        it{ should == [] }
      end
    end
  end

  describe "#order_by_distance" do
    let(:current_location){ {lat: nil, lng: nil, radius: nil} }
    subject{ Place.order_by_distance(current_location[:lat], current_location[:lng]) }
    before(:all) do
      @place_1 = Place.create!(:lat => 52.370216, :lng => 4.895168) #Amsterdam
      @place_2 = Place.create!(:lat => 52.520007, :lng => 13.404954) #Berlin
    end
    after(:all) do
      @place_1.destroy
      @place_2.destroy
    end

    context "when sorting on distance" do
      let(:current_location){{lat: 51.511214, lng: 0.119824}} #London
      it{ should == [@place_1, @place_2] }
    end

    context "when sorting on distance from another location" do
      let(:current_location){{lat: 52.229676, lng: 21.012229}} #Warsaw
      it{ should == [@place_2, @place_1] }
    end
  end

  describe "#selecting_distance_from" do
    let(:current_location){ {lat: nil, lng: nil, radius: nil} }
    subject do
      Place.
        order_by_distance(current_location[:lat], current_location[:lng]).
        selecting_distance_from(current_location[:lat], current_location[:lng]).
        first.
        try{|p| [p.data, p.distance.to_f] }
    end
    before(:all) do
      @place = Place.create!(:data => 'Amsterdam', :lat => 52.370216, :lng => 4.895168) #Amsterdam
    end
    after(:all) do
      @place.destroy
    end
    context "when selecting distance" do
      let(:current_location){{lat: 52.229676, lng: 21.012229}} #Warsaw
      it{ should == ["Amsterdam", 1095013.87438311] }
    end
  end
end
