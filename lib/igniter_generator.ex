defmodule LightningLibgraph.IgniterGenerator do
  def generate(pub_key_path, outgoing_chan_id, output_pub_key, amount, max_fee) do
    hops_pub_keys = Enum.join(pub_key_path, "\n  ")

    """
    declare pub_keys=(
      #{hops_pub_keys}
      #{output_pub_key}
    )

    AMOUNT=#{amount}
    OUTGOING_CHAN_ID=#{outgoing_chan_id}
    MAX_FEE=#{max_fee}
    """
  end
end
