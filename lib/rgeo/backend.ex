defmodule RGeo.Backend do
  use GenServer, restart: :permanent

  @resolution 5

  def start_link(options \\ [{:provinces, 10}, {:cities, 10}]) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @doc false
  def init(options) do
    {:ok, %{}, {:continue, {:load, options}}}
    # RGeo.Data.load(options)
  end

  def handle_continue({:load, options}, _) do
    {:ok, data} = RGeo.Data.load(options)
    {:noreply, data}
  end

  def reverse_geocode(%RGeo.Location{} = location) do
    GenServer.call(__MODULE__, {:reverse_geocode, location})
  end

  @spec location_at(Geo.Point.t()) ::
          {:ok, %RGeo.Location{}} | {:error, :not_found} | {:error, :loading}
  def location_at(%Geo.Point{} = point) do
    GenServer.call(__MODULE__, {:location_at, point})
  catch
    :exit, _ -> {:error, :loading}
  end

  def handle_call({:location_at, point}, _from, state) do
    {:ok, cell} = H3Geo.point_to_cell(point, @resolution)

    case Map.get(state, cell, nil) do
      nil ->
        {:reply, {:error, :not_found}, state}

      geoemtries ->
        props =
          Enum.reduce(geoemtries, %{}, fn geo, acc ->
            case Topo.contains?(geo, point) do
              true ->
                Map.merge(acc, geo.properties, fn
                  _, v1, nil when not is_nil(v1) -> v1
                  _, nil, v2 when not is_nil(v2) -> v2
                  _, nil, nil -> nil
                  _, v1, _ -> v1
                end)

              false ->
                acc
            end
          end)

        {:reply, {:ok, struct(RGeo.Location, props)}, state}
    end

    # Enum.map(state[cell], fn geometry -> geometry.properties end) |> IO.inspect()

    # result =
    #   state.geometries
    #   |> Stream.filter(fn geometry -> Topo.contains?(geometry, point) end)
    #   |> Stream.map(fn geometry -> geometry.properties end)
    #   |> Enum.to_list()
    #   |> Enum.reduce(%{}, fn geometries, acc ->
    #     Map.merge(acc, geometries, fn
    #       _, v1, nil when not is_nil(v1) -> v1
    #       _, nil, v2 when not is_nil(v2) -> v2
    #       _, _, v2 -> v2
    #     end)
    #   end)
  end
end
