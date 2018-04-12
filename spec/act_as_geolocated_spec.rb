require "spec_helper"

describe "ActiveRecord::Base.act_as_geolocated" do
  describe "ActiveRecord::Base" do
    context "when using .where with a model instance as a placeholder" do
      let(:place) { Place.create! }
      subject { Place.where("id = ?", place).first }
      after { place.destroy! }

      it { is_expected.to eq place }
    end
  end

  describe "#within_box" do
    let(:test_data) { { lat: nil, lng: nil, radius: nil } }

    subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

    before(:all) { @place = Place.create!(lat: -30.0277041, lng: -51.2287346) }
    after(:all) { @place.destroy }

    context "when query with null data" do
      it { is_expected.to be_empty }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }

      it { is_expected.to eq [@place] }
    end

    context "when query for place within the box" do
      let(:test_data) { { radius: 4_000_000, lat: -27.5969039, lng: -48.5494544 } }

      it { is_expected.to eq [@place] }
    end

    context "when query for place within the box, but outside the radius" do
      let(:test_data) { { radius: 300_000, lat: -27.5969039, lng: -48.5494544 } }

      it "the place shouldn't be within the radius" do
        expect(Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng])).to be_empty
      end

      it { is_expected.to eq [@place] }
    end

    context "when query for place outside the box" do
      let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to be_empty }
    end

    context "when joining tables that are also geoloacted" do
      let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }

      subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

      it "should work with objects having columns with the same name" do
        expect do
          Place
            .joins(:events)
            .within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a
        end.to_not raise_error
      end

      it "should work with nested associations" do
        expect do
          Event
            .joins(:events)
            .within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a
        end.to_not raise_error
      end
    end
  end

  describe "#within_box with miles" do
    let(:test_data) { { lat: nil, lng: nil, radius: nil } }

    subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

    before(:all) { 
      Place.acts_as_geolocated distance_unit: :miles
      @place = Place.create!(lat: -30.0277041, lng: -51.2287346) 
    }
    after(:all) { 
      Place.acts_as_geolocated
      @place.destroy 
    }

    context "when query with null data" do
      it { is_expected.to be_empty }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }
      
      it { is_expected.to eq [@place] }
    end

    context "when query for place within the box" do
      let(:test_data) { { radius: 2400, lat: -27.5969039, lng: -48.5494544 } }

      it { is_expected.to eq [@place] }
    end

    context "when query for place within the box, but outside the radius" do
      let(:test_data) { { radius: 186, lat: -27.5969039, lng: -48.5494544 } }

      it "the place shouldn't be within the radius" do
        expect(Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng])).to be_empty
      end

      it { is_expected.to eq [@place] }
    end

    context "when query for place outside the box" do
      let(:test_data) { { radius: 0.62, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to be_empty }
    end

    context "when joining tables that are also geoloacted" do
      let(:test_data) { { radius: 0.62, lat: -27.5969039, lng: -48.5494544 } }

      subject { Place.within_box(test_data[:radius], test_data[:lat], test_data[:lng]) }

      it "should work with objects having columns with the same name" do
        expect do
          Place
            .joins(:events)
            .within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a
        end.to_not raise_error
      end

      it "should work with nested associations" do
        expect do
          Event
            .joins(:events)
            .within_radius(test_data[:radius], test_data[:lat], test_data[:lng]).to_a
        end.to_not raise_error
      end
    end
  end

  describe "#within_radius" do
    let(:test_data) { { lat: nil, lng: nil, radius: nil } }
    subject { Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng]) }
    before(:all) do
      @place = Place.create!(lat: -30.0277041, lng: -51.2287346)
    end

    after(:all) do
      @place.destroy
    end

    context "when query with null data" do
      it { is_expected.to eq [] }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }
      it { is_expected.to eq [@place] }
    end

    context "when query for place within radius" do
      let(:test_data) { { radius: 4_000_000, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to eq [@place] }
    end

    context "when query for place outside the radius" do
      let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to eq [] }
    end

    context "uses lat and long of through table" do
      subject do
        Job.within_radius(test_data[:radius], test_data[:lat], test_data[:lng])
      end

      before(:all) do
        @event = Event.create!(lat: -30.0277041, lng: -51.2287346)
        @job = Job.create!(event: @event)
      end

      after(:all) do
        @event.destroy
        @job.destroy
      end

      context "when query with null data" do
        it { is_expected.to eq [] }
      end

      context "when query for the exact same point with radius 0" do
        let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }
        it { is_expected.to eq [@job] }
      end

      context "when query for place within radius" do
        let(:test_data) { { radius: 4_000_000, lat: -27.5969039, lng: -48.5494544 } }
        it { is_expected.to eq [@job] }
      end

      context "when query for place outside the radius" do
        let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }
        it { is_expected.to eq [] }
      end
    end
  end

  describe "#within_radius with miles" do
    let(:test_data) { { lat: nil, lng: nil, radius: nil } }
    subject { Place.within_radius(test_data[:radius], test_data[:lat], test_data[:lng]) }
    before(:all) do
      # Place.distance_unit = :miles
      Place.acts_as_geolocated distance_unit: :miles
      @place = Place.create!(lat: -30.0277041, lng: -51.2287346)
    end

    after(:all) do
      Place.acts_as_geolocated
      @place.destroy
    end

    context "when query with null data" do
      it { is_expected.to eq [] }
    end

    context "when query for the exact same point with radius 0" do
      let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }
      it { is_expected.to eq [@place] }
    end

    context "when query for place within radius" do
      let(:test_data) { { radius: 2400, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to eq [@place] }
    end

    context "when query for place outside the radius" do
      let(:test_data) { { radius: 0.62, lat: -27.5969039, lng: -48.5494544 } }
      it { is_expected.to eq [] }
    end

    context "uses lat and long of through table" do
      subject do
        Job.within_radius(test_data[:radius], test_data[:lat], test_data[:lng])
      end

      before(:all) do
        @event = Event.create!(lat: -30.0277041, lng: -51.2287346)
        @job = Job.create!(event: @event)
      end

      after(:all) do
        @event.destroy
        @job.destroy
      end

      context "when query with null data" do
        it { is_expected.to eq [] }
      end

      context "when query for the exact same point with radius 0" do
        let(:test_data) { { lat: -30.0277041, lng: -51.2287346, radius: 0 } }
        it { is_expected.to eq [@job] }
      end

      context "when query for place within radius" do
        let(:test_data) { { radius: 4_000_000, lat: -27.5969039, lng: -48.5494544 } }
        it { is_expected.to eq [@job] }
      end

      context "when query for place outside the radius" do
        let(:test_data) { { radius: 1000, lat: -27.5969039, lng: -48.5494544 } }
        it { is_expected.to eq [] }
      end
    end
  end

  describe "#order_by_distance" do
    let(:current_location) { { lat: nil, lng: nil, radius: nil } }

    subject { Place.order_by_distance(current_location[:lat], current_location[:lng]) }

    before(:all) do
      @amsterdam = Place.create!(lat: 52.370216, lng: 4.895168)
      @berlin = Place.create!(lat: 52.520007, lng: 13.404954) # Berlin
      @event_in_amsterdam = Event.create!(lat: 52.370216, lng: 4.895168)
      @event_in_berlin = Event.create!(lat: 52.520007, lng: 13.404954)
      @amsterdam_job = Job.create!(event: @event_in_amsterdam)
      @berlin_job = Job.create!(event: @event_in_berlin)
    end

    after(:all) do
      @amsterdam.destroy
      @berlin.destroy
      @event_in_amsterdam.destroy
      @event_in_berlin.destroy
      @amsterdam_job.destroy
      @berlin_job.destroy
    end

    context "uses lat and long of through table" do
      subject do
        Job.order_by_distance(current_location[:lat], current_location[:lng])
      end

      let(:current_location) { { lat: 51.511214, lng: 0.119824 } } # London
      it { is_expected.to eq [@amsterdam_job, @berlin_job] }
    end

    context "when sorting on distance" do
      let(:current_location) { { lat: 51.511214, lng: 0.119824 } } # London
      it { is_expected.to eq [@amsterdam, @berlin] }
    end

    context "when sorting on distance from another location" do
      let(:current_location) { { lat: 52.229676, lng: 21.012229 } } # Warsaw
      it { is_expected.to eq [@berlin, @amsterdam] }
    end
  end

  describe "#selecting_distance_from" do
    let(:current_location) { { lat: nil, lng: nil, radius: nil } }
    subject do
      Place
        .order_by_distance(current_location[:lat], current_location[:lng])
        .selecting_distance_from(current_location[:lat], current_location[:lng])
        .first
        .try { |p| [p.data, p.distance.to_f] }
    end
    before(:all) do
      @place = Place.create!(data: "Amsterdam", lat: 52.370216, lng: 4.895168) # Amsterdam
    end
    after(:all) do
      @place.destroy
    end
    context "when selecting distance" do
      let(:current_location) { { lat: 52.229676, lng: 21.012229 } } # Warsaw
      it { is_expected.to eq ["Amsterdam", 1_095_013.87438311] }
    end

    context "through table" do

      subject { Job.all.selecting_distance_from(current_location[:lat], current_location[:lng]).first }

      before(:all) do
        @event = Event.create!(lat: -30.0277041, lng: -51.2287346)
        @job = Job.create!(event: @event)
      end

      after(:all) do
        @event.destroy
        @job.destroy
      end

      context "when selecting distance" do
        it { is_expected.to respond_to :distance }
      end
    end
  end

  describe "#selecting_distance_from with miles" do
    let(:current_location) { { lat: nil, lng: nil, radius: nil } }
    subject do
      Place
        .order_by_distance(current_location[:lat], current_location[:lng])
        .selecting_distance_from(current_location[:lat], current_location[:lng])
        .first
        .try { |p| [p.data, p.distance.to_f] }
    end
    before(:all) do
      Place.acts_as_geolocated distance_unit: :miles
      @place = Place.create!(data: "Amsterdam", lat: 52.370216, lng: 4.895168) # Amsterdam
    end
    after(:all) do
      Place.acts_as_geolocated
      @place.destroy
    end
    context "when selecting distance" do
      let(:current_location) { { lat: 52.229676, lng: 21.012229 } } # Warsaw
      it { is_expected.to eq ["Amsterdam", 680.410076641856] }
    end

    context "through table" do

      subject { Job.all.selecting_distance_from(current_location[:lat], current_location[:lng]).first }

      before(:all) do
        @event = Event.create!(lat: -30.0277041, lng: -51.2287346)
        @job = Job.create!(event: @event)
      end

      after(:all) do
        @event.destroy
        @job.destroy
      end

      context "when selecting distance" do
        it { is_expected.to respond_to :distance }
      end
    end
  end
end
