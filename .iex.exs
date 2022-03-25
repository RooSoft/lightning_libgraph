LightningLibgraph.subscribe_events()

g = LightningLibgraph.load_graph

path = g
|> LightningLibgraph.Path.get_shortest(
  "02fe80fb6a2dc0fb6e9bec49c76d048889c91355d4e900fcb026bf095665790325",
  "033d8656219478701227199cbd6f670335c8d408a92ae88b962c49d4dc0e83e025"
)

igniter_config = path
|> LightningLibgraph.IgniterGenerator.generate(
  801202028628672512,
  "037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764",
  500_000,
  100
)

IO.puts igniter_config
