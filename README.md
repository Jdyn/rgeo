# RGeo

RGeo is an extremely basic reverse geocoding library that provides location information based on a given `%Geo.Point{}`.

The library currently only provides extremely basic location information down to the country level. The goal was to only spend about an hour on the current iteration so there is a lot of features missing.

`RGeo` loads the entire countries dataset with 100m resolution into memory. Data is sourced from [naturalearthdata.com](https://www.naturalearthdata.com/)

**NOTE: Not tested thoroughly in production**.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rgeo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rgeo, "~> 0.0.1-dev"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/rgeo>.

## Example Usage

`RGeo` uses the [felt/geo](https://github.com/felt/geo) library to represent GeoJSON.

```Elixir
  # Add the RGeo.Backend to your supervision tree.
  # In a Phoenix application, it it would be a link in your children

  # Application.ex
  ...
  children = [
    RGeo.Backend
  ]

  Supervisor.start_link(children, opts)
  ...
```

```Elixir
  # Calling the library in your application
  RGeo.location_at(%Geo.Point{coordinates: {-74.0060, 40.7128}})
  {:ok, %RGeo.Location{
          continent: "North America",
          country: "United States of America",
          country_code2: "US",
          country_code3: "USA",
          country_long: "United States of America",
          region: "Americas",
          subregion: "Northern America"
        }}

```
