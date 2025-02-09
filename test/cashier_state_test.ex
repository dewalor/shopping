defmodule CashierStateTest do
  use ExUnit.Case, async: true

  test "stores and gets state" do
    {:ok, state_pid_309} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState309")})
    {:ok, pid_1} = CashierSupervisor.start_child({Cashier, [[:SR1,:SR1,:SR1], state_pid_309]})

    GenServer.call(pid_1, :total)
    state = CashierState.get(state_pid_309)
    assert Map.get(state, :processed) == %{SR1: {3,1350}}
  end

  test "initializes with the correct state" do
    {:ok, state_pid_9} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState9")})

    state = CashierState.get(state_pid_9)
    assert Map.get(state, :processed) == %{}
    assert Map.get(state, :unprocessed) == []
    assert Map.get(state, :state_pid) == state_pid_9
  end

  test "updates state" do
    {:ok, state_pid_7} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState7")})

    CashierState.update(state_pid_7, {%{GR1: {2,311}}, [], state_pid_7})
    state = CashierState.get(state_pid_7)
    assert Map.get(state, :processed) == %{GR1: {2,311}}
  end
end
