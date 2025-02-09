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
  # prices are in GBP pence, e.g. 311 = £3.11
  @price_list %{:GR1 => 311, :SR1 => 500, :CF1 => 1123}

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: CashierStateSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: CashierSupervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def check_out(basket: "") do
    "0"
  end

  def check_out(basket) when Kernel.is_binary(basket) do
    basket = String.split(basket, ",", trim: true) |> validate()
    {:ok, state_pid} = CashierStateSupervisor.start_child({CashierState, []})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [basket, state_pid]})
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

    Enum.filter(products, &(&1 in Map.keys(@price_list)))
  end

  defp to_GBP_string(pennies) when pennies > 0 do
    {string_1, string_2} = Integer.to_string(pennies) |> String.split_at(-2)
    "£" <> string_1 <> "." <> string_2
  end

  defp to_GBP_string(0) do
    "0"
  end

  def calculate_total_price(:CF1, quantity, _) do
    # 3 or more coffees, the price of all coffees should drop to two thirds of the original price
    price = get_price!(:CF1)
    if quantity >= 3 do
      quantity * price
        |> Decimal.mult(2)
        |> Decimal.div(3)
        |> Decimal.round(0, :half_up)
        |> Decimal.to_integer()
    else
      quantity * price
    end
  end

  def calculate_total_price(product, quantity, total_price) do
    price = get_price!(product)
    total_price + price + calculate_discount(product, quantity, price)
  end

  def get_price!(product) do
    Map.fetch!(@price_list, product)
  end

  defp calculate_discount(:GR1, quantity, price) do
    # buy-one-get-one-free green tea; subtract full price of tea for every other green tea
    if rem(quantity, 2) == 0, do: -1 * price, else: 0
  end

  defp calculate_discount(:SR1, quantity, price) do
    # 3 or more strawberries, the price = £4.50/strawberry; subtract difference between price and 4.50 per strawberry
    # If this is the third strawberry, apply 3 unit discounts.  If this is the 4th or more, 1 unit discount
    cond do
      quantity > 3 -> -1 * (price - 450)
      quantity == 3 -> -1 * 3 * (price - 450)
      true -> 0
    end
  end

  defp calculate_discount(_, _, _) do
    0
  end
end
