defmodule RGeo.Backend do
  use GenServer

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @doc false
  def init(_options) do
    {:ok, [], {:continue, :load_data}}
  end

  def reverse_geocode(%RGeo.Location{} = location) do
    GenServer.call(__MODULE__, {:reverse_geocode, location})
  end

  def handle_continue(:load_data, _state) do
    {:ok, state} = RGeo.Data.load()
    {:noreply, state}
  end

  @spec location_at(Geo.Point.t()) :: {:ok, %RGeo.Location{}} | {:error, :unknown}
  def location_at(%Geo.Point{} = point) do
    GenServer.call(__MODULE__, {:location_at, point})
  end

  def handle_call({:location_at, point}, _from, state) do
    result =
      state
      |> Enum.reduce_while({:error, :unknown}, fn {_name, geometry}, _acc ->
        case Topo.contains?(geometry, point) do
          true ->
            {:halt, {:ok, struct(RGeo.Location, geometry.properties)}}

          false ->
            {:cont, {:error, :unknown}}
        end
      end)

    {:reply, result, state}
  end
end
