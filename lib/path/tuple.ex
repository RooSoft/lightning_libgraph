defmodule LightningLibgraph.Path.Tuple do
  def from_path(path) do
    convert_path_to_tuples(path, [])
    |> Enum.reverse()
  end

  defp convert_path_to_tuples([_], tuples) do
    tuples
  end

  defp convert_path_to_tuples(path, tuples) do
    [_ | rest] = path

    tuple = extract_tuple(path)

    convert_path_to_tuples(rest, [tuple | tuples])
  end

  defp extract_tuple([first | [second | _]]) do
    {first, second}
  end
end
