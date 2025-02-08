defmodule Cashier do
  use GenServer
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
  def init(basket) when is_list basket do
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
  def handle_call(:total, from, {processed, [product | tail] = _unprocessed}) do
    # processed e.g. %{GR1: {1, 311}}, i.e. %{product: {total quantity, total price}}

    processed = Map.update(
                  processed,
                  product,
                  {1, Shopping.get_price!(product)},
                  fn {qty, total_price} -> {qty + 1, Shopping.calculate_total_price(product, qty + 1, total_price)} end
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

  @impl true
  def handle_info({:EXIT, _from, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def terminate(_reason, state) do
    #Logger.info "terminating #{reason}"
    state
  end
end
