defmodule LightningLibgraph.Lnd.GraphDownloader do
  use GenServer

  alias LightningLibgraph.Lnd.GraphDownloader.Channels
  alias LightningLibgraph.Lnd.GraphDownloader.Nodes

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      %{}
      |> Map.put(:subscribers, []),
      name: __MODULE__
    )
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def load(g, cert, macaroon, url, args \\ []) do
    GenServer.cast(__MODULE__, {:load, {g, cert, macaroon, url, args}})
  end

  def subscribe() do
    GenServer.call(__MODULE__, {:subscribe, self()})
  end

  @impl true
  def handle_call({:subscribe, pid}, _from, state) do
    {
      :reply,
      :ok,
      state
      |> Map.put(:subscribers, [pid | state.subscribers])
    }
  end

  @impl true
  def handle_cast({:load, {g, cert, macaroon, url, args}}, state) do
    [min_channel_size: min_channel_size] = args

    send_to_subscribers({:downloading}, state.subscribers, :load)

    lnd_graph = get_graph(cert, macaroon, url)

    send_to_subscribers({:parsing}, state.subscribers, :load)

    graph = Jason.decode!(lnd_graph)

    send_to_subscribers({:importing_nodes}, state.subscribers, :load)

    graph_with_nodes =
      graph["nodes"]
      |> Enum.filter(fn node -> node["last_update"] > 0 end)
      |> Nodes.insert(g)

    send_to_subscribers({:importing_channels}, state.subscribers, :load)

    final_graph =
      graph["edges"]
      |> Enum.filter(fn edge -> edge["last_update"] > 0 end)
      |> Enum.filter(fn edge ->
        {capacity, _} = Integer.parse(edge["capacity"])

        capacity >= min_channel_size
      end)
      |> Channels.insert(graph_with_nodes)

    send_to_subscribers({:done, final_graph}, state.subscribers, :load)

    {:noreply, state}
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

  defp send_to_subscribers(payload, subscribers, topic) do
    subscribers
    |> Enum.each(fn subscriber ->
      send(subscriber, {:graph_downloader, topic, payload})
    end)
  end
end
