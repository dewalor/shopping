defmodule Shopping.Dispatcher do
  @moduledoc """
  Receives baskets and assigns them to cashiers.
  """
  use GenServer
  alias Shopping.{Cashier, CashierPool}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    state = %{
      assignments: [],
      baskets_buffer: [],
      checked_out_baskets: [],
    }

    {:ok, state}
  end

  def scan_basket(basket) do
    GenServer.cast(__MODULE__, {:scan_basket, basket})
  end

  def get_total(basket_id) do
    GenServer.call(__MODULE__, {:get_total, basket_id})
  end

  @impl true
  def handle_cast({:scan_basket, basket}, state) do
    IO.puts "received basket #{inspect basket} "

    response = case CashierPool.available_cashier do
      {:ok, cashier} ->
        IO.puts "cashier #{inspect cashier} acquired, assigning basket"
        Process.monitor(cashier)

        new_state = assign_basket(state, basket, cashier)
        CashierPool.flag_cashier_busy(cashier)
        total = Cashier.calculate_total(cashier, basket)
        totaled_basket = Map.put_new(basket, :total, total)
        new_state = Map.update(new_state, :checked_out_baskets, [totaled_basket], &([totaled_basket | &1]) )

        {:noreply, new_state}
      {:error, message} ->
        IO.puts "#{message}"
        state = buffer_basket(state, basket)
        IO.puts "buffering basket #{inspect basket}"
        {message, state}
    end

    response
  end

  @impl true
  def handle_call({:get_total, id}, _from, state) do
    basket = state.checked_out_baskets
      |> Enum.find(fn basket -> basket.basket_id == id end)
    if basket == nil, do: Shopping.Dispatcher.get_total(id)
    total = Map.fetch(basket, :total)

    {:reply, total, state}
  end

  @impl true
  def handle_info({:cashier_idle, cashier}, state) do
    CashierPool.flag_cashier_idle(cashier)

    state = if Kernel.length(state.baskets_buffer) > 0 do
      [ basket | remaining_baskets] = state.baskets_buffer
      scan_basket(basket)
      %{state | baskets_buffer: remaining_baskets}
    else
      state
    end

    {:noreply, state}
  end

  #TODO
  @impl true
  def handle_info({:DOWN, _ref, :process, cashier, reason}, state) do
    IO.puts "cashier #{inspect cashier} went down. details: #{inspect reason}"
    failed_assignments = filter_by_cashier(cashier, state.assignments)
    failed_basket = failed_assignments |> Enum.map(fn({basket, _pid}) -> basket end)
    CashierPool.remove_cashier(cashier)
    assignments = state.assignments -- failed_assignments
    state = %{state | assignments: assignments}
    scan_basket(failed_basket)
    {:noreply, state}
  end

  defp assign_basket(state, basket, cashier) do
    Map.update(state, :assignments, [{basket, cashier}], fn assignments ->
      assignments ++ {basket, cashier}
     end)
    state
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
