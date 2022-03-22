defmodule LightningLibgraph.Lnd.GraphDownloader.Nodes do
  def insert(nodes, g) do
    nodes
    |> Enum.reduce(g, fn node, g ->
      node |> add_node(g)
    end)
  end

  defp add_node(node, g) do
    pub_key = node["pub_key"]

    g
    |> Graph.add_vertex(pub_key)
    |> Graph.label_vertex(pub_key, %{alias: node["alias"]})
  end
end
