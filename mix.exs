defmodule LightningLibgraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :lightning_libgraph,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:csv, "~> 2.4"},
      {:libgraph, "~> 0.13.3"},
      {:hackney, "~> 1.18"}
    ]
  end
end
