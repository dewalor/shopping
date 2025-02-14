defmodule CashierSupervisorTest do
  use ExUnit.Case, async: true
  alias Shopping.Cashier

  test "can start 10000 cashiers" do
    for _n <- 1..10000 do
      {:ok, pid} = Cashier.start
      Cashier.total(pid, [:GR1,:GR1])
      assert is_pid(pid)
    end
  end
end
