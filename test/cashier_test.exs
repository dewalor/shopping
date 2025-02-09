defmodule CashierTest do
  use ExUnit.Case, async: true

  test "gives the right total when given a valid product list" do
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [:GR1]})
    assert GenServer.call(pid, :total) == 311
  end

  test "throws match error when given an invalid params" do
    assert_raise MatchError, fn ->
      {:ok, _} = CashierSupervisor.start_child({Cashier, "GR1"})
    end
  end

  test "terminates with :ok" do
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [:GR1]})
    GenServer.call(pid, :total)

    assert :ok =  GenServer.stop(pid)

  end
end
