defmodule LightningLibgraph.Neighbors do
  def get_common_peers(g, source_pub_key, destination_pub_key) do
    source_neighbors = g |> Graph.neighbors(source_pub_key)
    destination_neighbors = g |> Graph.neighbors(destination_pub_key)

    ## first, get all from source that's not in destination
    ## and then remove them from source, leaving only common peers
    source_neighbors -- source_neighbors -- destination_neighbors
  end
end
