defmodule Cashier do
  use GenServer
  require Logger
  # Client

  def start_link(default) when is_list default do
    [basket, state_pid] = default
    GenServer.start_link(__MODULE__, {%{}, basket, state_pid})
  end

  def total(pid) do
    GenServer.call(pid, :total)
  end

  def stop(pid) do
    GenServer.stop(pid, :normal, :infinity)
  end

  # Server (callbacks)
  @impl true
  def init({%{}, basket, state_pid}) when is_list basket do
    Process.flag(:trap_exit, true)

    initial_state = {%{}, basket, state_pid} # {processed/checked out, unprocessed, state_pid}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:total, _from, {processed, [], state_pid}) do
    total = Map.values(processed)
              |> Enum.map(fn {_, product_total} -> product_total end)
              |> Enum.sum()

    CashierState.update(state_pid, {processed, [], state_pid})
    {:reply, total, {processed, [], state_pid}}
  end

  @impl true
  def handle_call(:total, from, {processed, [product | tail] = _unprocessed, state_pid}) do
    # processed = %{product: {total quantity, total price}}
    processed = Map.update(
                  processed,
                  product,
                  {1, Shopping.get_price!(product)},
                  fn {qty, total_price} -> {qty + 1, Shopping.calculate_total_price(product, qty + 1, total_price)} end
                )
                new_state = {processed, tail, state_pid}

                CashierState.update(state_pid, {processed, tail, state_pid})
                handle_call(:total, from, new_state)
  end

  @impl true
  def handle_info({_tag, _from, reason}, state) do
    {:stop, reason, state}
  end

  @impl true
  def terminate(_reason, {_processed, _unprocessed, state_pid} = new_state) do
 #   Logger.info "terminating #{reason}"
    CashierState.update(state_pid, new_state)
    {:no_reply, new_state}
  end
end
