defmodule RGeo.Data do
  @type scope :: :countries | :provinces | :cities
  @type resolution :: 110 | 30 | 10

  @type datasets :: list({scope(), resolution()})

  @doc """
  """
  @spec load() :: {:ok, map()}
  def load() do
    data =
      RGeo.app_name()
      |> :code.priv_dir()
      |> List.to_string()
      |> Path.join(parse_filename({"Countries", 110}))
      |> to_charlist()
      |> File.read!()
      |> :zlib.gunzip()
      |> Jason.decode!()
      |> Geo.JSON.decode!()
      |> then(& &1.geometries)
      |> Enum.reduce(%{}, fn geometry, acc ->
        if geometry.properties["name"] == "New York" do
          IO.inspect(geometry.properties, limit: :infinity)
        end

        geometry =
          put_in(geometry.properties, %{
            country: geometry.properties["NAME"],
            country_long: geometry.properties["FORMAL_EN"],
            country_code3: geometry.properties["ISO_A3"],
            country_code2: geometry.properties["ISO_A2"],
            continent: geometry.properties["CONTINENT"],
            region: geometry.properties["REGION_UN"],
            subregion: geometry.properties["SUBREGION"]
          })

        Map.put(acc, geometry.properties.country, geometry)
      end)

    {:ok, data}
  end

  defp parse_filename({scope, resolution}) when is_binary(scope) and is_number(resolution) do
    "#{String.capitalize(scope)}#{resolution}.gz"
  end
end
