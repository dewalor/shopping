defmodule CashierPoolTest do
  use ExUnit.Case
  alias Shopping.{CashierPool}

  setup do
    start_supervised!({CashierPool, name: TestCashierPool})

    state = :sys.get_state(TestCashierPool)
    state.cashiers
    |> Enum.each(fn({pid, _status}) -> GenServer.call(TestCashierPool, {:remove_cashier, pid}) end)

  {:ok, server: TestCashierPool}
  end

  describe "#available_cashier" do
    test "fetches and adds idle cashier", context do
      {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})

      state = :sys.get_state(context[:server])
      assert is_pid(pid)
      assert Enum.count(state.cashiers) > 0
    end

    test "fetches idle cashier", context do
      {:ok, _} = GenServer.call(context[:server], {:fetch_available_cashier})
      {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})

      state = :sys.get_state(context[:server])
      assert is_pid(pid)
      assert Enum.count(state.cashiers) > 0
    end

    test "returns error when maxed out", context do
      state = :sys.get_state(context[:server])
      number_to_add = state.max - Enum.count(state.cashiers)
      Stream.repeatedly(fn() ->
        {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})
        GenServer.call(context[:server],  {:flag_cashier, :busy, pid})
      end)
      |> Enum.take(number_to_add)

      response = GenServer.call(context[:server], {:fetch_available_cashier})
      assert {:error, _} = response
    end
  end

  describe "#remove_cashier" do
    test "removes cashier", context do
      {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})
      GenServer.call(context[:server], {:remove_cashier, pid})
      state = :sys.get_state(context[:server])
      refute(Enum.member?(state.cashiers, {pid, :idle}))
    end
  end

  describe "#flag_cashier_busy" do
    test "flags cashier busy", context do
      {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})
      GenServer.call(context[:server],  {:flag_cashier, :busy, pid})
      state = :sys.get_state(context[:server])
      assert(Enum.member?(state.cashiers, {pid, :busy}))
    end
  end

  describe "#flag_cashier_idle" do
    test "flags cashier idle", context do
      {:ok, pid} = GenServer.call(context[:server], {:fetch_available_cashier})
      {:ok, pid_1} = GenServer.call(context[:server], {:fetch_available_cashier})
      GenServer.call(context[:server],  {:flag_cashier, :busy, pid})
      GenServer.call(context[:server],  {:flag_cashier, :idle, pid_1})
      state = :sys.get_state(context[:server])
      assert(Enum.member?(state.cashiers, {pid_1, :idle}))
    end
  end

end
