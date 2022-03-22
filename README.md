# LightningLibgraph

Heavily based on [Tony Hammond's Native graph data in Elixir](https://medium.com/@tonyhammond/native-graph-data-in-elixir-8c0bb325d451)

## Prerequisite
Make sure you rename `config.secret.exs.template` to `config.secret.exs` and fill out with the appropriate info


## Usage
In IEx, just issue that command

```elixir
g = LightningLibgraph.load_graph
```

And then `g` will contain the lightning network graph.
