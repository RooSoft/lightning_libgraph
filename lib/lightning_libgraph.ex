defmodule LightningLibgraph do
  alias LightningLibgraph.Lnd

  def load_graph do
    Lnd.GraphDownloader.start_link(nil)
    Lnd.GraphDownloader.subscribe()

    Graph.new()
    |> Lnd.GraphDownloader.load(
      Application.fetch_env!(:lightning_libgraph, :cert),
      Application.fetch_env!(:lightning_libgraph, :macaroon),
      Application.fetch_env!(:lightning_libgraph, :url)
    )

    get_messages()
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
