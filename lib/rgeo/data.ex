defmodule RGeo.Data do
  alias Geo.GeometryCollection

  @type scope :: :countries | :provinces | :cities
  @type resolution :: 110 | 30 | 10

  @type datasets :: list({scope(), resolution()})

  @spec load(options :: datasets()) :: {:ok, map()}
  def load(options \\ [{:provinces, 10}]) do
    data =
      Enum.reduce(options, %GeometryCollection{}, fn {scope, resolution}, acc ->
        Map.put(acc, :geometries, acc.geometries ++ parse_data({scope, resolution}))
      end)

    {:ok, data}
  end

  defp parse_data({scope, resolution}) when is_atom(scope) and is_number(resolution) do
    RGeo.app_name()
    |> :code.priv_dir()
    |> List.to_string()
    |> Path.join(parse_filename({scope, resolution}))
    |> to_charlist()
    |> File.read!()
    |> :zlib.gunzip()
    |> Jason.decode!()
    |> Geo.JSON.decode!()
    |> then(& &1.geometries)
    |> Enum.reduce([], fn geometry, acc ->
      geometry =
        put_in(geometry.properties, %{
          country: geometry.properties["NAME"],
          country_long: geometry.properties["FORMAL_EN"],
          country_code3: geometry.properties["ISO_A3"],
          country_code2: geometry.properties["ISO_A2"],
          continent: geometry.properties["CONTINENT"],
          region: geometry.properties["REGION_UN"],
          subregion: geometry.properties["SUBREGION"],
          province: geometry.properties["name"],
          city: String.trim_trailing(geometry.properties["name_conve"] || "", "2")
        })

      acc ++ [geometry]
    end)
  end

  @spec parse_filename({scope(), resolution()}) :: String.t()
  defp parse_filename({scope, resolution})
       when scope in [:cities, :provinces, :countries] and resolution in [10] do
    "#{String.capitalize(Atom.to_string(scope))}#{resolution}.gz"
  end
end
