require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @test_place = Place.create!(:lat => -30.0277041, :lng => -51.2287346)
  end

  test "can find place within radius" do
    assert_equal [@test_place], Place.within_radius(0, -30.0277041, -51.2287346).all 
    assert_equal [@test_place], Place.within_radius(400000, -27.5969039, -48.5494544).all
    assert_equal [@test_place], Place.within_radius(4000000, -27.5969039, -48.5494544).all
  end
  test "won't find the place if radius is 0" do
    assert_equal [], Place.within_radius(0, -27.5969039, -48.5494544).all
  end
  test "won't find places outside the radius" do
    assert_equal [], Place.within_radius(1000, -27.5969039, -48.5494544).all
  end
  test "can handle more than one place" do
    another_place = Place.create! :lat => -27.5969039, :lng => -48.5494544
    assert_equal [@test_place], Place.within_radius(0, -30.0277041, -51.2287346).all
    assert_equal [another_place], Place.within_radius(0, -27.5969039, -48.5494544).all
    assert_equal [another_place], Place.within_radius(1000, -27.5969039, -48.5494544).all 
    assert_equal Set.new([@test_place, another_place]), Set.new(Place.within_radius(400000, -27.5969039, -48.5494544).all)
    assert_equal Set.new([@test_place, another_place]), Set.new(Place.within_radius(4000000,-27.5969039, -48.5494544).all)
  end
end
