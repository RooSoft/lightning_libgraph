defmodule LightningLibgraph.Lnd.GraphDownloader.Payload do
  def parse(lnd_graph) do
    Jason.decode!(lnd_graph)
  end
end
