defmodule LightningLibgraph.Lnd.GraphDownloader do
  alias LightningLibgraph.Lnd.GraphDownloader.Channels
  alias LightningLibgraph.Lnd.GraphDownloader.Nodes

  def load(g, cert, macaroon, url) do
    IO.puts("downloading...")
    lnd_graph = get_graph(cert, macaroon, url)

    IO.puts("parsing...")
    graph = Jason.decode!(lnd_graph)

    IO.puts("importing nodes...")

    graph_with_nodes =
      graph["nodes"]
      |> Enum.filter(fn node -> node["last_update"] > 0 end)
      |> Nodes.insert(g)

    IO.puts("importing channels...")

    final_graph =
      graph["edges"]
      |> Enum.filter(fn edge -> edge["last_update"] > 0 end)
      |> Channels.insert(graph_with_nodes)

    IO.puts("done!")

    final_graph
  end

  defp get_headers(macaroon_filename) do
    [
      {'Grpc-Metadata-macaroon', macaroon_filename |> read_macaroon |> to_charlist}
    ]
  end

  defp read_macaroon(macaroon_filename) do
    File.read!(macaroon_filename) |> Base.encode16()
  end

  defp get_options(cert_filename) do
    [ssl: [cacertfile: cert_filename]]
  end

  defp get_graph(cert_filename, macaroon_filename, url) do
    headers = get_headers(macaroon_filename)
    request = {String.to_charlist(url), headers}
    options = get_options(cert_filename)

    case :httpc.request(:get, request, options, []) do
      {:ok, {{_v, 200, _m}, _h, body}} -> :erlang.list_to_binary(body)
    end
  end
end
