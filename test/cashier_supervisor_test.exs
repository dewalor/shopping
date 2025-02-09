defmodule CashierSupervisorTest do
  use ExUnit.Case, async: true

  test "can start 10000 cashiers" do
    for _n <- 1..10000 do
      {:ok, state_pid_11} = CashierStateSupervisor.start_child({CashierState, []})
      {:ok, pid} =CashierSupervisor.start_child({Cashier, [["GR1","GR1"], state_pid_11]})
      assert is_pid(pid)
    end
  end
end
