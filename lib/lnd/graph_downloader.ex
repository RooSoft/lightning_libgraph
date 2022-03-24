defmodule LightningLibgraph.Lnd.GraphDownloader do
  use GenServer

  alias LightningLibgraph.Lnd.GraphDownloader.{Http, Payload, Channels, Nodes}

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

  def load(cert, macaroon, url, args \\ []) do
    GenServer.cast(__MODULE__, {:load, {cert, macaroon, url, args}})
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
  def handle_cast({:load, {cert, macaroon, url, args}}, state) do
    [min_channel_size: min_channel_size] = args

    %{g: g} =
      download(cert, macaroon, url, state.subscribers)
      |> parse(state.subscribers)
      |> create_graph()
      |> import_nodes(state.subscribers)
      |> import_channels(min_channel_size, state.subscribers)

    send_to_subscribers({:done, g}, state.subscribers, :load)

    {:noreply, state}
  end

  defp download(cert, macaroon, url, subscribers) do
    send_to_subscribers({:downloading}, subscribers, :load)

    Http.get_graph(cert, macaroon, url)
  end

  defp parse(payload, subscribers) do
    send_to_subscribers({:parsing}, subscribers, :load)

    %{payload: Payload.parse(payload)}
  end

  defp create_graph(context) do
    context
    |> Map.put(:g, Graph.new())
  end

  defp import_nodes(%{payload: payload, g: g} = context, subscribers) do
    send_to_subscribers({:importing_nodes}, subscribers, :load)

    g = Nodes.import(payload["nodes"], g)

    context
    |> Map.put(:g, g)
  end

  defp import_channels(%{payload: payload, g: g} = context, min_channel_size, subscribers) do
    send_to_subscribers({:importing_channels}, subscribers, :load)

    g = Channels.import(payload["edges"], g, min_channel_size)

    context
    |> Map.put(:g, g)
  end

  defp send_to_subscribers(payload, subscribers, topic) do
    subscribers
    |> Enum.each(fn subscriber ->
      send(subscriber, {:graph_downloader, topic, payload})
    end)
  end
end
