defmodule RGeo.Data do
  @type scope :: :countries | :provinces | :cities
  @type resolution :: 110 | 30 | 10

  @type datasets :: list({scope(), resolution()})

  @resolution 3

  @spec load(options :: datasets()) :: {:ok, map()}
  def load(options \\ []) do
    data =
      Enum.reduce(options, %{}, fn {scope, resolution}, acc ->
        data = parse_data({scope, resolution})

        Map.merge(acc, data, fn
          _, v1, v2 -> v1 ++ v2
        end)
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
    # |> Enum.take(10)
    |> Enum.reduce(%{}, fn geometry, geo_data ->
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
          city:
            Map.get(geometry.properties, "name_conve", "")
            |> String.trim_trailing("2")
            |> String.trim_trailing("1")
            |> case do
              "" -> nil
              city -> city
            end
        })

      try do
        cells =
          case geometry do
            %Geo.Polygon{} = geometry ->
              {:ok, cells} = H3Geo.polygon_to_cells(geometry, @resolution)
              cells

            %Geo.MultiPolygon{} = geometry ->
              {:ok, cells} = H3Geo.multipolygon_to_cells(geometry, @resolution)
              cells
          end

        Enum.reduce(cells, geo_data, fn cell, acc ->
          value = Map.drop(geometry, [:coordinates])
          Map.update(acc, cell, [value], fn existing -> [value | existing] end)
        end)
      rescue
        _ ->
          geo_data
      end
    end)
  end

  @spec parse_filename({scope(), resolution()}) :: String.t()
  defp parse_filename({scope, resolution})
       when scope in [:cities, :provinces, :countries] and resolution in [10] do
    "#{String.capitalize(Atom.to_string(scope))}#{resolution}.gz"
  end
end
