require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @test_place = Place.create!(:lat => -30.0277041, :lng => -51.2287346)
  end

  test "the truth" do
    assert_equal [@test_place], Place.within_radius(-30.0277041, -51.2287346, 0).all 
    assert_equal [], Place.within_radius(-27.5969039, -48.5494544, 0).all
    assert_equal [], Place.within_radius(-27.5969039, -48.5494544, 1000).all
    assert_equal [@test_place], Place.within_radius(-27.5969039, -48.5494544, 400000).all
    assert_equal [@test_place], Place.within_radius(-27.5969039, -48.5494544, 4000000).all
    another_place = Place.create! :lat => -27.5969039, :lng => -48.5494544
    assert_equal [@test_place], Place.within_radius(-30.0277041, -51.2287346, 0).all
    assert_equal [another_place], Place.within_radius(-27.5969039, -48.5494544, 0).all
    assert_equal [another_place], Place.within_radius(-27.5969039, -48.5494544, 1000).all 
    assert_equal Set.new([@test_place, another_place]), Set.new(Place.within_radius(-27.5969039, -48.5494544, 400000).all)
    assert_equal Set.new([@test_place, another_place]), Set.new(Place.within_radius(-27.5969039, -48.5494544, 4000000).all)
  end
end
