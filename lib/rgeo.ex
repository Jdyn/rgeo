defmodule RGeo do
  @moduledoc """
  Documentation for `RGeo`.

  RGeo is an extremely basic reverse geocoding library that provides location information based on a given `%Geo.Point{}`.

  The library currently only provides extremely basic location information down to only the country level.
  """

  @doc """
  Returns the OTP app name of :rgeo

  """
  def app_name do
    :rgeo
  end

  @doc """
  Returns location information associated with a given `%Geo.Point{}`

  Currently only supports reverse geocoding upto the country level.

  ## Examples

        iex> RGeo.location_at(%Geo.Point{coordinates: {-74.0060, 40.7128}})
        {:ok, %Location{
                continent: "North America",
                country: "United States of America",
                country_code2: "US",
                country_code3: "USA",
                country_long: "United States of America",
                region: "Americas",
                subregion: "Northern America"
              }}
  """
  @spec location_at(Geo.Point.t()) :: {:ok, %RGeo.Location{}} | {:error, :unknown}
  def location_at(%Geo.Point{} = point) do
    RGeo.Backend.location_at(point)
  end
end
