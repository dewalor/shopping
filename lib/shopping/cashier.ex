defmodule Shopping.Cashier do
  use GenServer
  require Logger
  alias Shopping.Dispatcher

  def start do
    GenServer.start(__MODULE__, [])
  end

  def calculate_total(pid,  %{items: items, basket_id: basket_id}) when is_list items do
    GenServer.cast(pid, {:calculate_total, %{processed: %{}, unprocessed: items, basket_id: basket_id}})
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    initial_state = {%{}, []} # {processed/checked out, unprocessed}
    {:ok, initial_state}
  end

  @impl true
  def handle_cast({:calculate_total, %{processed: processed, unprocessed: [], basket_id: basket_id}}, _state) do
    total = Map.values(processed)
              |> Enum.map(fn {_, product_total} -> product_total end)
              |> Enum.sum()

    new_state = %{total: total, processed: processed, unprocessed: [], basket_id: basket_id}
    send(Dispatcher, {:basket_totaled, new_state})
    send(Dispatcher, {:cashier_idle, self()})
   {:noreply, new_state}
  end

  @impl true
  def handle_cast({:calculate_total, %{processed: processed, unprocessed: [product | tail], basket_id: basket_id}}, _state) do
    # processed = %{product: {total quantity, total price}}
    processed = Map.update(
      processed,
                  product,
                  {1, Shopping.get_price!(product)},
                  fn {qty, total_price} -> {qty + 1, Shopping.calculate_total_price(product, qty + 1, total_price)} end
                )
                new_state = %{processed: processed, unprocessed: tail, basket_id: basket_id}
                handle_cast({:calculate_total, new_state}, new_state)
  end

  @impl true
  def terminate(reason, new_state) do
    Logger.info "terminating #{reason}"
    {:no_reply, new_state}
  end
end
