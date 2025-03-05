defmodule CashierTest do
  use ExUnit.Case, async: true

  setup do
    # Generate unique names for each test
    state_supervisor_name = :"TestCashierStateSupervisor_#{:erlang.unique_integer([:positive])}"
    cashier_supervisor_name = :"TestCashierSupervisor_#{:erlang.unique_integer([:positive])}"

    state_supervisor_child_spec = %{
      id: CashierStateSupervisor,
      start: {CashierStateSupervisor, :start_link, [[state_supervisor_name]]}
    }

    cashier_supervisor_child_spec = %{
      id: CashierSupervisor,
      start: {CashierSupervisor, :start_link, [[cashier_supervisor_name]]}
    }

    {:ok, _} = start_supervised(state_supervisor_child_spec)
    {:ok, _} = start_supervised(cashier_supervisor_child_spec)

    :ok
  end

  test "gives the right total when given a valid product list" do
    {:ok, state_pid_0} = CashierStateSupervisor.start_child({CashierState, []})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:GR1], state_pid_0]})
    assert GenServer.call(pid, :total) == 311
  end

  test "throws function clause error when given an invalid params" do
      {:ok, state_pid_1} = CashierStateSupervisor.start_child({CashierState, []})
      assert_raise MatchError, fn ->
        {:ok, _} = CashierSupervisor.start_child({Cashier, ["GR1", state_pid_1]})
      end
  end

  test "stores state when it terminates" do
    {:ok, state_pid_2} = CashierStateSupervisor.start_child({CashierState, []})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:CF1], state_pid_2]})
    GenServer.call(pid, :total)

    GenServer.stop(pid)
    state = CashierState.get(state_pid_2)
    assert Map.get(state, :processed) == %{CF1: {1,1123}}
  end
end
