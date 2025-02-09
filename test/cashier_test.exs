defmodule CashierTest do
  use ExUnit.Case, async: true

  test "gives the right total when given a valid product list" do
    {:ok, state_pid_0} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("Supervisor1")})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:GR1], state_pid_0]})
    assert GenServer.call(pid, :total) == 311
  end

  test "throws function clause error when given an invalid params" do
      {:ok, state_pid_1} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("Supervisor2")})
      assert_raise MatchError, fn ->
        {:ok, _} = CashierSupervisor.start_child({Cashier, ["GR1", state_pid_1]})
      end
  end

  test "terminates with :ok" do
    {:ok, state_pid_2} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("Supervisor3")})
    {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:GR1], state_pid_2]})
    GenServer.call(pid, :total)

    assert :ok =  GenServer.stop(pid)
  end
end
