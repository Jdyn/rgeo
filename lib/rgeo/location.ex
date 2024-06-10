defmodule RGeo.Location do
  @type t :: %__MODULE__{
          country: String.t(),
          country_long: String.t(),
          country_code2: String.t(),
          country_code3: String.t(),
          continent: String.t(),
          region: String.t(),
          subregion: String.t(),
          province: String.t(),
          city: String.t()
        }

  @enforce_keys [
    :country,
    :country_long,
    :country_code2,
    :country_code3,
    :continent,
    :region,
    :subregion,
    :province,
    :city
  ]

  defstruct @enforce_keys
end
