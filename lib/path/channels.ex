defmodule LightningLibgraph.Path.Channels do
  alias LightningLibgraph.Path.Tuple

  def from_path(path, g) do
    path
    |> Tuple.from_path()
    |> Enum.reduce([], fn tuple, renders ->
      [convert_tuple_to_channel(tuple, g) | renders]
    end)
    |> Enum.reverse()
  end

  defp convert_tuple_to_channel({node_out, node_in}, g) do
    g
    |> convert_tuple_to_channel(node_out, node_in)
  end

  defp convert_tuple_to_channel(g, node_out, node_in) do
    g
    |> Graph.out_edges(node_out)
    |> Enum.find(fn edge -> edge.v2 == node_in end)
  end
end
