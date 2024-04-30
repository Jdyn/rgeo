defmodule RGeo.MixProject do
  use Mix.Project

  def project do
    [
      app: :rgeo,
      version: "0.0.1-dev",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "RGeo",
      package: package(),
      source_url: "https://github.com/Jdyn/rgeo",
      docs: [
        main: "RGeo",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "RGeo",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog*),
      links: %{"GitHub" => "https://github.com/Jdyn/rgeo"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4.1"},
      {:geo, "~> 3.6.0"},
      {:topo, "~> 1.0"},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end
end
