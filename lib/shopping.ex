defmodule Shopping do
  @moduledoc """
  Documentation for `Shopping`.
  """

  @doc """
  Gives the total price of all items in the shopping cart.

  ## Examples

      iex> Shopping.check_out("GR1")
      311

  """
  def check_out("") do
    0
  end

  def check_out(basket) when Kernel.is_binary(basket) do
    {:ok, pid} = GenServer.start_link(Cashier, String.split(basket, ",", trim: true))
    GenServer.call(pid, :total)
  end
end
