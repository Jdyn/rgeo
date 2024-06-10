defmodule RGeoTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = RGeo.Backend.start_link([{:provinces, 10}, {:cities, 10}])
    :ok
  end

  test "Returns valid location for New York coordinates" do
    {:ok, result} = RGeo.location_at(%Geo.Point{coordinates: {-74.0060, 40.7128}})

    assert result == %RGeo.Location{
             continent: "North America",
             country: "United States of America",
             country_code2: "US",
             country_code3: "USA",
             country_long: "United States of America",
             region: "Americas",
             subregion: "Northern America",
             province: "New York",
             city: "New York"
           }
  end
end
