defmodule LightningLibgraph.PathFinder do
  def shortest_path(g, source_pub_key, destination_pub_key) do
    Graph.dijkstra(g, source_pub_key, destination_pub_key)
  end
end
