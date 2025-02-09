defmodule CashierTest do
  use ExUnit.Case, async: true

  test "gives the right total when given a valid product list" do
    {:ok, state_pid_0} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("Supervisor1")})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:GR1], state_pid_0]})
    assert GenServer.call(pid, :total) == 311
  end

  test "throws function clause error when given an invalid params" do
      {:ok, state_pid_1} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState22")})
      assert_raise MatchError, fn ->
        {:ok, _} = CashierSupervisor.start_child({Cashier, ["GR1", state_pid_1]})
      end
  end

  test "stores state when it terminates" do
    {:ok, state_pid_2} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState293")})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:CF1], state_pid_2]})
    GenServer.call(pid, :total)

    GenServer.stop(pid)
    state = CashierState.get(state_pid_2)
    assert Map.get(state, :processed) == %{CF1: {1,1123}}
  end
end
