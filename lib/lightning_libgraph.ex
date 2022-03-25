defmodule LightningLibgraph do
  use Supervisor

  alias LightningLibgraph.Lnd

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Lnd.GraphDownloader
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def subscribe_events do
    Lnd.GraphDownloader.subscribe()
  end

  def load_graph do
    Lnd.GraphDownloader.load(
      Application.fetch_env!(:lightning_libgraph, :cert),
      Application.fetch_env!(:lightning_libgraph, :macaroon),
      Application.fetch_env!(:lightning_libgraph, :url),
      amount: 500_000
    )

    get_messages()
  end

  def remove_channel(g, channel) do
    g
    |> Graph.delete_edge(channel.v1, channel.v2, channel.label)
  end

  def get_messages() do
    receive do
      {:graph_downloader, :load, {:downloading}} ->
        IO.inspect("downloading......")
        get_messages()

      {:graph_downloader, :load, {:parsing}} ->
        IO.inspect("parsing......")
        get_messages()

      {:graph_downloader, :load, {:importing_nodes}} ->
        IO.inspect("importing nodes......")
        get_messages()

      {:graph_downloader, :load, {:importing_channels}} ->
        IO.inspect("importing channels.....")
        get_messages()

      {:graph_downloader, :load, {:done, final_graph}} ->
        IO.inspect("done!!!")

        final_graph
    end
  end
end
