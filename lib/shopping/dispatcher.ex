defmodule Shopping.Dispatcher do
  @moduledoc """
  Receives baskets and assigns them to cashiers.
  """
  use GenServer
  alias Shopping.{Cashier, CashierPool}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    state = %{
      assignments: [],
      baskets_buffer: [],
      checked_out_baskets: [],
    }

    {:ok, state}
  end

  def receive_basket(basket) do
    GenServer.cast(__MODULE__, {:receive_basket, basket})
  end

  def handle_cast({:receive_basket, basket}, state) do
    IO.puts "received basket #{inspect basket} "

    state = case CashierPool.available_cashier do
      {:ok, cashier} ->
        IO.puts "cashier #{inspect cashier} acquired, assigning basket"
        Process.monitor(cashier)
        state = assign_basket(state, basket, cashier)
        CashierPool.flag_cashier_busy(cashier)
        Cashier.total(cashier, basket)
        state
      {:error, message} ->
        IO.puts "#{message}"
        state = buffer_basket(state, basket)
        IO.puts "buffering basket #{inspect basket}"
        state
    end

    {:noreply, state}
  end

  def handle_info({:cashier_idle, cashier}, state) do
    CashierPool.flag_cashier_idle(cashier)

    state = if Kernel.length(state.baskets_buffer) > 0 do
      [ basket | remaining_baskets] = state.baskets_buffer
      receive_basket(basket)
      %{state | baskets_buffer: remaining_baskets}
    else
      state
    end

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, cashier, reason}, state) do
    IO.puts "cashier #{inspect cashier} went down. details: #{inspect reason}"
    failed_assignments = filter_by_cashier(cashier, state.assignments)
    failed_basket = failed_assignments |> Enum.map(fn({basket, _pid}) -> basket end)
    CashierPool.remove_cashier(cashier)
    assignments = state.assignments -- failed_assignments
    state = %{state | assignments: assignments}
    receive_basket(failed_basket)
    {:noreply, state}
  end

  defp assign_basket(state, basket, cashier) do
    assignments = state.assignments ++ {basket, cashier}
    %{state | assignments: assignments}
  end

  defp buffer_basket(state, basket) do
    baskets_buffer = state.baskets_buffer ++ basket
    %{state | baskets_buffer: baskets_buffer}
  end

  defp filter_by_cashier(cashier, assignments) do
    assignments
    |> Enum.filter(fn({_basket, assigned_cashier}) ->
      assigned_cashier == cashier
    end)
  end
end
