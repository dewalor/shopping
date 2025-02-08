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
  @products [:GR1, :SR1, :CF1]

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: CashierSupervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def check_out(basket: "") do
    "0"
  end

  def check_out(basket) when Kernel.is_binary(basket) do
    basket = String.split(basket, ",", trim: true) |> validate()
    {:ok, pid} = CashierSupervisor.start_child({Cashier, basket})
    reply = GenServer.call(pid, :total)

    case reply do
      x when is_integer(x) -> to_GBP_string(x)
      error -> error
    end
  end

  defp validate(products) when is_list products do
    products = Enum.map(products, fn product ->
      String.to_existing_atom(product)
    end)

    Enum.filter(products, &(&1 in @products))
  end

  defp to_GBP_string(pennies) when pennies > 0 do
    {string_1, string_2} = Integer.to_string(pennies) |> String.split_at(-2)
    "£" <> string_1 <> "." <> string_2
  end

  defp to_GBP_string(0) do
    "0"
  end
end
