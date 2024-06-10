defmodule RGeo.Backend do
  use GenServer

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @doc false
  def init(_options) do
    {:ok, state} = RGeo.Data.load()
    {:ok, state}
  end

  def reverse_geocode(%RGeo.Location{} = location) do
    GenServer.call(__MODULE__, {:reverse_geocode, location})
  end

  @spec location_at(Geo.Point.t()) :: {:ok, %RGeo.Location{}} | {:error, :unknown}
  def location_at(%Geo.Point{} = point) do
    GenServer.call(__MODULE__, {:location_at, point})
  end

  def handle_call({:location_at, point}, _from, state) do
    result =
      state.geometries
      |> Stream.filter(fn geometry -> Topo.contains?(geometry, point) end)
      |> Stream.map(fn geometry -> geometry.properties end)
      |> Enum.to_list()
      |> Enum.reduce(%{}, fn geometries, acc ->
        Map.merge(acc, geometries, fn
          _, v1, nil when not is_nil(v1) -> v1
          _, nil, v2 when not is_nil(v2) -> v2
          _, _, v2 -> v2
        end)
      end)

    {:reply, {:ok, struct(RGeo.Location, result)}, state}
  end
end
