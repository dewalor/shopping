defmodule Cashier do
  use GenServer
  require Logger
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
    Process.flag(:trap_exit, true)

    initial_state = {%{}, basket} # {processed/checked out, unprocessed}
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
    # processed = %{product: {total quantity, total price}}
    processed = Map.update(
                  processed,
                  product,
                  {1, Shopping.get_price!(product)},
                  fn {qty, total_price} -> {qty + 1, Shopping.calculate_total_price(product, qty + 1, total_price)} end
                )

                handle_call(:total, from, {processed, tail})
  end

  @impl true
  def handle_info({:EXIT, _from, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def handle_info({:kill, _from, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info "terminating #{reason}"
    state
  end
end
