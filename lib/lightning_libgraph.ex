defmodule LightningLibgraph do
  alias LightningLibgraph.Lnd

  def load_graph do
    Graph.new()
    |> Lnd.GraphDownloader.load(
      Application.fetch_env!(:lightning_libgraph, :cert),
      Application.fetch_env!(:lightning_libgraph, :macaroon),
      Application.fetch_env!(:lightning_libgraph, :url)
    )
  end
end
