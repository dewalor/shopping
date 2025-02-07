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
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: CashierSupervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def check_out(basket: "") do
    0
  end

  def check_out(basket) when Kernel.is_binary(basket) do
    basket = String.split(basket, ",", trim: true)
    {:ok, pid} = CashierSupervisor.start_child({Cashier, basket})

    GenServer.call(pid, :total)
  end
end
