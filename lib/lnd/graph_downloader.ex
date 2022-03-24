defmodule LightningLibgraph.Lnd.GraphDownloader do
  use GenServer

  alias LightningLibgraph.Lnd.GraphDownloader.{Http, Channels, Nodes}

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

    lnd_graph = Http.get_graph(cert, macaroon, url)

    send_to_subscribers({:parsing}, state.subscribers, :load)

    graph = parse(lnd_graph)

    send_to_subscribers({:importing_nodes}, state.subscribers, :load)

    g = Nodes.import(graph["nodes"], g)

    send_to_subscribers({:importing_channels}, state.subscribers, :load)

    g = Channels.import(graph["edges"], g, min_channel_size)

    send_to_subscribers({:done, g}, state.subscribers, :load)

    {:noreply, state}
  end

  defp parse(lnd_graph) do
    Jason.decode!(lnd_graph)
  end

  defp send_to_subscribers(payload, subscribers, topic) do
    subscribers
    |> Enum.each(fn subscriber ->
      send(subscriber, {:graph_downloader, topic, payload})
    end)
  end
end
