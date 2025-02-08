defmodule CashierSupervisorTest do
  use ExUnit.Case, async: true

  test "starts Cashier with pid when given a list" do
    {:ok, pid} = CashierSupervisor.start_child({Cashier, ["GR1"]})
    assert is_pid(pid)
  end

  test "does not process invalid product list" do
    case CashierSupervisor.start_child({Cashier, "GR1"}) do
      {:ok, pid} when is_pid(pid) ->  flunk("this should not have happened")
      _ -> :ok
    end
  end

  test "can start 10000 cashiers" do
    for _n <- 1..10000 do
      {:ok, pid} =CashierSupervisor.start_child({Cashier, ["GR1","GR1"]})
      assert is_pid(pid)
    end
  end
end
