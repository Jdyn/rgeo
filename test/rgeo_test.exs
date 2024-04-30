defmodule RGeoTest do
  use ExUnit.Case

  test "greets the world" do
    RGeo.Backend.start_link()
    {:ok, result} = RGeo.location_at(%Geo.Point{coordinates: {-74.0060, 40.7128}})

    assert result == %RGeo.Location{
             continent: "North America",
             country: "United States of America",
             country_code2: "US",
             country_code3: "USA",
             country_long: "United States of America",
             region: "Americas",
             subregion: "Northern America"
           }
  end
end
