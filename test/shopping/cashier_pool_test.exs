defmodule CashierPoolTest do
  use ExUnit.Case
  alias Shopping.{CashierPool}

  setup do
    # set CashierPool to initial state
    state = :sys.get_state(CashierPool)
    state.cashiers
    |> Enum.each(fn({pid, _status}) -> CashierPool.remove_cashier(pid) end)
  end

  describe "#available_cashier" do
    test "fetches and adds idle cashier" do
      {:ok, pid} = CashierPool.available_cashier
      state = :sys.get_state(CashierPool)
      assert is_pid(pid)
      assert Enum.count(state.cashiers) > 0
    end

    test "fetches idle cashier" do
      {:ok, _} = CashierPool.available_cashier
      {:ok, pid} = CashierPool.available_cashier
      state = :sys.get_state(CashierPool)
      assert is_pid(pid)
      assert Enum.count(state.cashiers) > 0
    end

    test "returns error when maxed out" do
      state = :sys.get_state(CashierPool)
      number_to_add = state.max - Enum.count(state.cashiers)
      Stream.repeatedly(fn() ->
        {:ok, pid} = CashierPool.available_cashier
        CashierPool.flag_cashier_busy(pid)
      end)
      |> Enum.take(number_to_add)

      response = CashierPool.available_cashier

      assert {:error, _} = response
    end
  end

  describe "#remove_cashier" do
    test "removes cashier" do
      {:ok, pid} = CashierPool.available_cashier
      CashierPool.remove_cashier(pid)
      state = :sys.get_state(CashierPool)
      refute(Enum.member?(state.cashiers, {pid, :idle}))
    end
  end

  describe "#flag_cashier_busy" do
    test "flags cashier busy" do
      {:ok, pid} = CashierPool.available_cashier
      CashierPool.flag_cashier_busy(pid)
      state = :sys.get_state(CashierPool)
      assert(Enum.member?(state.cashiers, {pid, :busy}))
    end
  end

  describe "#flag_cashier_idle" do
    test "flags cashier idle" do
      {:ok, pid} = CashierPool.available_cashier
      CashierPool.flag_cashier_busy(pid)
      CashierPool.flag_cashier_idle(pid)
      state = :sys.get_state(CashierPool)
      assert(Enum.member?(state.cashiers, {pid, :idle}))
    end
  end

end
