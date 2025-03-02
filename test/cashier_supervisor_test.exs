defmodule CashierSupervisorTest do
  use ExUnit.Case, async: true

  test "starts a Cashier child with the provided products and state_pid" do
    state_child_spec = %{
      id: CashierStateSupervisor,
      start: {CashierStateSupervisor, :start_link, [[:TestCashierStateSupervisor]]}
    }

    state_pid = start_supervised(state_child_spec)

    child_spec = %{
      id: CashierSupervisor,
      start: {CashierSupervisor, :start_link, [[:TestCashierSupervisor]]}
    }
    start_supervised!(child_spec)

    products = [:GR1, :SR1, :CF1]  # Use atoms instead of strings

    {:ok, cashier_pid} = CashierSupervisor.start_child({Cashier, [products, state_pid]})

    assert is_pid(cashier_pid)
    # Verify the cashier processes the products correctly
    IO.inspect(cashier_pid, label: "*******************************************************")
    total = GenServer.call(cashier_pid, :total)
    IO.inspect(total, label: "TOTAL:::::::::::::::::::::::::::::::::::::::::")
    assert is_integer(total)
    assert total > 0
  end

  test "supervisor restarts child when it crashes" do
    start_supervised(CashierStateSupervisor)
    start_supervised(CashierSupervisor)

    {:ok, state_pid} = CashierStateSupervisor.start_child({CashierState, []})
    {:ok, cashier_pid} = CashierSupervisor.start_child({Cashier, [[:GR1], state_pid]})  # Use atom instead of string

    # Get the supervisor's children before crash
    children_before = DynamicSupervisor.which_children(CashierSupervisor)

    # Kill the child process
    Process.exit(cashier_pid, :kill)

    # Wait a moment for the supervisor to restart the child
    :timer.sleep(100)

    # Get the supervisor's children after crash
    children_after = DynamicSupervisor.which_children(CashierSupervisor)

    # Verify the number of children remains the same
    assert length(children_before) == length(children_after)

    # Verify the PIDs are different (indicating a restart)
    _pids_before = Enum.map(children_before, fn {_, pid, _, _} -> pid end)
    pids_after = Enum.map(children_after, fn {_, pid, _, _} -> pid end)

    # The killed PID should not be in the list of current PIDs
    refute Enum.member?(pids_after, cashier_pid)
  end
end
