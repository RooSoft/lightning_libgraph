defmodule LightningLibgraph.Lnd.GraphDownloader.Channels do
  def import(edges, g, amount) do
    edges
    |> Enum.filter(fn edge -> edge["last_update"] > 0 end)
    |> Enum.filter(fn edge ->
      {capacity, _} = Integer.parse(edge["capacity"])

      capacity >= 4 * amount
    end)
    |> insert(g, amount)
  end

  defp insert(edges, g, amount) do
    g1 =
      edges
      |> Enum.reduce(g, fn edge, g ->
        add_channel(edge, g, "node1", "node2", amount)
      end)

    edges
    |> Enum.reduce(g1, fn edge, g ->
      add_channel(edge, g, "node2", "node1", amount)
    end)
  end

  defp add_channel(edge, g, source_node, destination_node, amount) do
    source_node_pub_key = edge["#{source_node}_pub"]
    destination_node_pub_key = edge["#{destination_node}_pub"]

    policy = edge["#{source_node}_policy"]
    weight = calculate_weight(policy, amount)

    g
    |> Graph.add_edge(
      Graph.Edge.new(destination_node_pub_key, source_node_pub_key,
        label: edge["channel_id"],
        weight: weight
      )
    )
  end

  defp calculate_weight(policy, amount) do
    base_fee = parse_base_rate(policy) / 1000
    rate = parse_rate(policy) / 1000

    base_fee + rate * amount
  end

  defp parse_rate(nil) do
    0
  end

  defp parse_rate(policy) do
    {rate, _} = Integer.parse(policy["fee_rate_milli_msat"])

    rate
  end

  defp parse_base_rate(nil) do
    0
  end

  defp parse_base_rate(policy) do
    {rate, _} = Integer.parse(policy["fee_base_msat"])

    rate
  end
end
