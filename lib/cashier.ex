defmodule Cashier do
  use GenServer
  # prices are in GBP pence, e.g. 311 = £3.11
  @price_list %{:GR1 => 311, :SR1 => 500, :CF1 => 1123}
  # Client

  def start_link(basket) when is_list basket do
    GenServer.start_link(__MODULE__, basket)
  end

  def total(pid) do
    GenServer.call(pid, :total)
  end

  def stop(pid) do
    GenServer.stop(pid, :normal, :infinity)
  end

  # Server (callbacks)

  @impl true
  def init(basket) do
    # the first element is a map of products in the basket that have been processed/checked out
    # the second element is the list of products in the basket that haven't been checked out, i.e. unprocessed
    initial_state = {%{}, basket}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:total, _from, {processed, []}) do
    total = Map.values(processed)
              |> Enum.map(fn {_, product_total} -> product_total end)
              |> Enum.sum()
    {:reply, total, {processed, []}}
  end

  @impl true
  def handle_call(:total, from, {processed, [head | tail] = _unprocessed}) do
    product = String.to_existing_atom(String.trim(head))
    # processed = %{GR1: {1, 311}} or %{product: {total quantity, total price}}
    price = Map.fetch!(@price_list, product)
    # discount = calculate_discount(product, processed, price)
    processed = Map.update(
                  processed,
                  product,
                  {1, price},
                  fn {qty, total_price} -> {qty + 1, calculate_total_price(product, qty + 1, total_price, price)} end
                )
    # the first element is the new map of checked out/processed products
    # the second element is the list of remaining unprocessed products to be checked out recursively
    handle_call(:total, from, {processed, tail})
  end

  # 3 or more coffees, the price of all coffees should drop to two thirds of the original price; subtract 1/3 price per coffee
  @impl true
  def handle_call(:subtract, _from, {total, discount, unprocessed_items}) do
    {:reply, discount, {total, unprocessed_items}}
  end

  defp calculate_total_price(:CF1, quantity, _, price) do
    # 3 or more coffees, the price of all coffees should drop to two thirds of the original price
    if quantity >= 3 do
      quantity * price
        |> Decimal.mult(2) |> Decimal.div(3) |> Decimal.round(0, :half_up) |> Decimal.to_integer()
    else
      quantity * price
    end
  end

  defp calculate_total_price(product, quantity, total_price, price) do
    total_price + price + calculate_discount(product, quantity, price)
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
