defmodule LightningLibgraph.Path do
  alias LightningLibgraph.Path.Tuple
  alias LightningLibgraph.Path.Channels

  def display(path, g) do
    path
    |> Channels.from_path(g)
  end

  def get_shortest(g, source_pub_key, destination_pub_key) do
    Graph.dijkstra(g, source_pub_key, destination_pub_key)
  end

  def find_channel(g, path, channel_id) do
    path
    |> Tuple.from_path()
    |> find_channel_from_tuples(g, channel_id)
  end

  defp find_channel_from_tuples(tuples, g, channel_id) do
    tuple =
      tuples
      |> Enum.find(fn tuple ->
        channel = convert_tuple_to_channel(g, tuple)

        channel.label == channel_id
      end)

    convert_tuple_to_channel(g, tuple)
  end

  defp convert_tuple_to_channel(_, nil) do
    nil
  end

  defp convert_tuple_to_channel(g, {tuple_source_node_pub_key, tuple_destination_node_pub_key}) do
    Graph.edges(g, tuple_source_node_pub_key)
    |> Enum.find(fn edge ->
      edge.v2 == tuple_destination_node_pub_key
    end)
  end
end
