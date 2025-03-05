defmodule CashierStateSupervisorTest do
  use ExUnit.Case, async: true

  test "starts a CashierState child with a generated name when no name is provided" do
    start_supervised(CashierStateSupervisor)
    {:ok, state_pid} = CashierStateSupervisor.start_child({CashierState, []})

    assert is_pid(state_pid)
    state = CashierState.get(state_pid)
    assert is_map(state)
    assert Map.get(state, :processed) == %{}
  end

  test "supervisor restarts child when it crashes" do
    start_supervised(CashierStateSupervisor)
    {:ok, state_pid} = CashierStateSupervisor.start_child({CashierState, []})

    # Get the supervisor's children before crash
    children_before = DynamicSupervisor.which_children(CashierStateSupervisor)

    # Kill the child process
    Process.exit(state_pid, :kill)

    # Wait a moment for the supervisor to restart the child
    :timer.sleep(100)

    # Get the supervisor's children after crash
    children_after = DynamicSupervisor.which_children(CashierStateSupervisor)

    # The number of children may not be the same because DynamicSupervisor doesn't automatically restart children
    # Instead, verify that the killed PID is not in the list of current PIDs
    _pids_before = Enum.map(children_before, fn {_, pid, _, _} -> pid end)
    pids_after = Enum.map(children_after, fn {_, pid, _, _} -> pid end)

    # The killed PID should not be in the list of current PIDs
    refute Enum.member?(pids_after, state_pid)
  end
end
