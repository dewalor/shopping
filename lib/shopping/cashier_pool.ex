defmodule Shopping.CashierPool do
  use GenServer
  alias Shopping.Cashier
  @max 10000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any()) :: {:ok, %{cashiers: [], max: 10000}}
  def init(_) do
    state = %{
      cashiers: [],
      max: @max,
    }

    {:ok, state}
  end

  @doc """
    returns {:ok, pid} or {:error, message}
  """
  def available_cashier do
    GenServer.call(__MODULE__, {:fetch_available_cashier})
  end

  def flag_cashier_busy(cashier) do
    GenServer.call(__MODULE__, {:flag_cashier, :busy, cashier})
  end

  def flag_cashier_idle(cashier) do
    GenServer.call(__MODULE__, {:flag_cashier, :idle, cashier})
  end

  def remove_cashier(cashier) do
    GenServer.call(__MODULE__, {:remove_cashier, cashier})
  end

  # Callbacks

  @doc """
    1. find idle cashier from the pool
    2. if none found, check if number of cashiers is less than max
    3. if less than max, start a new cashier, add to the pool as idle and return {:ok, pid}
    4. if over max, return {:error, message}
  """
  def handle_call({:fetch_available_cashier}, _from, state) do
    idle_cashier =
      state.cashiers
      |> Enum.find(&match?({_cashier, :idle}, &1))

    {status, message, state} = case idle_cashier do
      nil ->
        # either maxed out or all busy but there is room in the pool
        if Enum.count(state.cashiers) >= @max do
          {:error, "cashier pool maxed out", state}
        else
          {:ok, cashier} = Cashier.start
          cashier_entry = {cashier, :idle}
          cashiers = [cashier_entry | state.cashiers]
          state = %{state | cashiers: cashiers}
          {:ok, cashier, state}
        end
      {cashier, _status} ->
        # found idle cashier
        {:ok, cashier, state}
      response -> raise "unexpected format: #{inspect response}"
    end
    {:reply, {status, message}, state}
  end

  def handle_call({:flag_cashier, _flag, _cashier}, _from, state) when state.cashiers == [], do: {:reply, :ok, state}

  def handle_call({:flag_cashier, flag, cashier}, _from, state) do
    cashier_index =
      state.cashiers
      |> Enum.find_index(&match?({^cashier, _}, &1))

    state = if !is_nil(cashier_index) do
      cashiers = List.replace_at(state.cashiers, cashier_index, {cashier, flag})
      %{state | cashiers: cashiers}
    end
    {:reply, :ok, state}
  end

  def handle_call({:remove_cashier, _cashier}, _from, state) when state.cashiers == [], do: {:reply, :ok, state}

  def handle_call({:remove_cashier, cashier}, _from, state) do
    cashier_entry =
      state.cashiers
      |> Enum.find(&match?({^cashier, _}, &1))

    cashiers = List.delete(state.cashiers, cashier_entry)
    state = %{state | cashiers: cashiers}

    {:reply, :ok, state}
  end
end
