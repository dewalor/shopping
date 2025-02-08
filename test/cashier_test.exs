defmodule CashierTest do
  use ExUnit.Case, async: true

  test "gives the right total when given a valid product list" do
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [:GR1]})
    assert GenServer.call(pid, :total) == 311
  end
end
