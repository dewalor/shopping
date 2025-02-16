defmodule CashierSupervisorTest do
  use ExUnit.Case
  alias Shopping.Cashier

  setup do
    case stop_supervised(Shopping.Dispatcher) do
      {:error, :not_found} -> start_supervised(Shopping.Dispatcher)
      {_, _} -> :ok
    end

    case stop_supervised(Shopping.CashierPool) do
      {:error, :not_found} -> start_supervised(Shopping.CashierPool)
      {_, _} -> :ok
    end
    :ok
  end

  test "can start 1000 cashiers" do
    for _n <- 1..1000 do
      {:ok, pid} = Cashier.start
      basket_id = :rand.uniform(9999999999999999)
      assert Cashier.total(pid, %{items: [:GR1,:GR1], basket_id: basket_id}) == 311
      assert is_pid(pid)
    end
  end
end
