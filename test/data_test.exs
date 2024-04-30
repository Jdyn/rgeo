defmodule RGeo.DataTest do
  use ExUnit.Case

  test "unzips the gzip data" do
    {:ok, _data} = RGeo.Data.load()
  end
end
