defmodule CashierSupervisorTest do
  use ExUnit.Case, async: true

  test "starts a Cashier child with the provided products and state_pid" do
    # Generate unique names for this test
    state_supervisor_name = :"TestCashierStateSupervisor_#{:erlang.unique_integer([:positive])}"
    cashier_supervisor_name = :"TestCashierSupervisor_#{:erlang.unique_integer([:positive])}"
    state_name = :"TestCashierState_#{:erlang.unique_integer([:positive])}"

    state_supervisor_child_spec = %{
      id: CashierStateSupervisor,
      start: {CashierStateSupervisor, :start_link, [[state_supervisor_name]]}
    }

    {:ok, _state_supervisor_pid} = start_supervised(state_supervisor_child_spec)

    state_child_spec = %{
      id: CashierState,
      start: {CashierState, :start_link, [[state_name]]}
    }

    {:ok, state_pid} = start_supervised(state_child_spec)

    cashier_supervisor_child_spec = %{
      id: CashierSupervisor,
      start: {CashierSupervisor, :start_link, [[cashier_supervisor_name]]}
    }
    {:ok, _} = start_supervised(cashier_supervisor_child_spec)

    products = [:GR1, :SR1, :CF1]  # Use atoms instead of strings

    {:ok, cashier_pid} = CashierSupervisor.start_child({Cashier, [products, state_pid]})

    assert is_pid(cashier_pid)
    # Verify the cashier processes the products correctly
    total = GenServer.call(cashier_pid, :total)

    assert is_integer(total)
    assert total > 0
  end

  test "supervisor restarts child when it crashes" do
    # Generate unique names for this test
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
    {:ok, _supervisor_pid} = start_supervised(cashier_supervisor_child_spec)

    {:ok, state_pid} = CashierStateSupervisor.start_child({CashierState, []})

    # Start the cashier directly with the supervisor
    {:ok, cashier_pid} = DynamicSupervisor.start_child(
      cashier_supervisor_name,
      {Cashier, [[:GR1], state_pid]}
    )

    # Get the supervisor's children before crash
    children_before = DynamicSupervisor.which_children(cashier_supervisor_name)

    # Kill the child process
    Process.exit(cashier_pid, :kill)

    # Wait a moment for the supervisor to restart the child
    :timer.sleep(100)

    # Get the supervisor's children after crash
    children_after = DynamicSupervisor.which_children(cashier_supervisor_name)

    assert length(children_before) > 0
    assert length(children_before) == length(children_after)

    # Verify the PIDs are different (indicating a restart)
    _pids_before = Enum.map(children_before, fn {_, pid, _, _} -> pid end)
    pids_after = Enum.map(children_after, fn {_, pid, _, _} -> pid end)

    # The killed PID should not be in the list of current PIDs
    refute Enum.member?(pids_after, cashier_pid)
  end
end
