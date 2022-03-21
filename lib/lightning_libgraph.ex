defmodule LightningLibgraph do
  @priv_dir "#{:code.priv_dir(:lightning_libgraph)}"
  @csv_dir @priv_dir <> "/lightning/"

  def start do
    Graph.new()
    |> import_nodes()
    |> import_channels()
    |> Graph.info()
  end

  defp import_nodes(g) do
    File.stream!(@csv_dir <> "nodes.csv")
    |> CSV.decode(separator: ?,, headers: true)
    |> Enum.reduce(g, fn row, g ->
      {:ok, %{"pub_key" => pub_key, "alias" => node_alias, "color" => color}} = row

      g
      |> Graph.add_vertex(pub_key)
      |> Graph.label_vertex(pub_key, %{alias: node_alias, color: color})
    end)
  end

  defp import_channels(g) do
    File.stream!(@csv_dir <> "channels.csv")
    |> CSV.decode(separator: ?,, headers: true)
    |> Enum.reduce(g, fn row, g ->
      {:ok,
       %{
         "channel_id" => id,
         "node1_pub" => node1_pub,
         "node2_pub" => node2_pub
       }} = row

      g
      |> Graph.add_edge(Graph.Edge.new(node1_pub, node2_pub, label: id))
    end)
  end
end
