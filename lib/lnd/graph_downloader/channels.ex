defmodule LightningLibgraph.Lnd.GraphDownloader.Channels do
  def import(edges, g, min_channel_size) do
    edges
    |> Enum.filter(fn edge -> edge["last_update"] > 0 end)
    |> Enum.filter(fn edge ->
      {capacity, _} = Integer.parse(edge["capacity"])

      capacity >= min_channel_size
    end)
    |> insert(g)
  end

  defp insert(edges, g) do
    g1 =
      edges
      |> Enum.reduce(g, fn edge, g ->
        add_channel(edge, g, "node1_pub", "node2_pub")
      end)

    edges
    |> Enum.reduce(g1, fn edge, g ->
      add_channel(edge, g, "node2_pub", "node1_pub")
    end)
  end

  defp add_channel(edge, g, source_node_pub, destination_node_pub) do
    source_node_pub_key = edge[source_node_pub]
    destination_node_pub_key = edge[destination_node_pub]

    g
    |> Graph.add_edge(
      Graph.Edge.new(source_node_pub_key, destination_node_pub_key, label: "CHANNEL")
    )
  end
end
