defmodule Shopping.Cashier do
  use GenServer
  alias Shopping.Dispatcher

  def start do
    GenServer.start(__MODULE__, [])
  end

  def total(pid, basket) when is_list basket do
    GenServer.call(pid, {:total, {%{}, basket}})
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    initial_state = {%{}, []} # {processed/checked out, unprocessed}
    {:ok, initial_state}
  end

  def handle_call({:total, {processed, []}}, _from, _state) do
    total = Map.values(processed)
              |> Enum.map(fn {_, product_total} -> product_total end)
              |> Enum.sum()

    send(Dispatcher, {:cashier_idle, self()})
    {:reply, total, {processed, []}}
  end

  @impl true
  def handle_call({:total, {processed, [product | tail] = _unprocessed}}, from, _state) do
    # processed = %{product: {total quantity, total price}}
    processed = Map.update(
      processed,
                  product,
                  {1, Shopping.get_price!(product)},
                  fn {qty, total_price} -> {qty + 1, Shopping.calculate_total_price(product, qty + 1, total_price)} end
                )
                new_state = {processed, tail}
                handle_call({:total, new_state}, from, new_state)
  end
end
