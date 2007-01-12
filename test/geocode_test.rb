require File.join(File.dirname(__FILE__), 'test_helper')


class GeocodeTest < Test::Unit::TestCase
  fixtures :geocodes
  
  def test_distance_to
    washington_dc = geocodes(:white_house_geocode)
    chicago = geocodes(:chicago_geocode)
    
    distance_in_default_units = washington_dc.distance_to(chicago)
    distance_in_miles = washington_dc.distance_to(chicago, :miles)
    distance_in_kilometers = washington_dc.distance_to(chicago, :kilometers)
    
    assert_in_delta 594.820, distance_in_default_units, 1.0
    assert_in_delta 594.820, distance_in_miles, 1.0
    assert_in_delta 957.275, distance_in_kilometers, 1.0
  end
  
  def test_distance_with_invalid_geocode
    chicago = geocodes(:chicago_geocode)
    fake = Geocode.new
    
    assert !chicago.distance_to(fake)
    assert !chicago.distance_to(nil)
  end
 
  def test_instance_geocode
    result = nil
    
    # Ensure that when we query with the same value, we don't create a new Geocode
    assert_no_difference(Geocode, :count) do
      result = Geocode.find_or_create_by_query('Holland, MI')
      assert_equal geocodes(:holland), result
    end
  end
  
  def test_empty_query
    assert_no_difference(Geocode, :count) do
      empty = Geocode.create(:query => '')
      assert empty.new_record?
    end
  end
  
  def test_cooridnates
    assert_equal "-86.200722,42.654781", geocodes(:saugatuck_geocode).coordinates
  end

  def test_to_s
    assert_equal "-86.200722,42.654781", geocodes(:saugatuck_geocode).to_s
  end

  #
  # Helpers
  #
  def assert_geocode_result(result)
    assert_not_nil result
    assert result.latitude.is_a?(BigDecimal) || result.latitude.is_a?(Float), "latitude is a #{result.latitude.class.name}"
    assert result.longitude.is_a?(BigDecimal) || result.longitude.is_a?(Float)
    
    # Depending on the geocoder, we'll get slightly different results
    assert_in_delta 42.787567, result.latitude, 0.001
    assert_in_delta -86.109039, result.longitude, 0.001
  end
  
end