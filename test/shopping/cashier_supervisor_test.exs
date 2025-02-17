defmodule CashierSupervisorTest do
  use ExUnit.Case
  alias Shopping.Cashier

  setup do
    Application.stop(:shopping)
    :ok = Application.start(:shopping)
    :ok
  end

  test "can start 1000 cashiers" do
    for _n <- 1..1000 do
      {:ok, pid} = Cashier.start
      basket_id = :rand.uniform(9999999999999999)
      :ok = Cashier.calculate_total(pid, %{items: [:GR1,:GR1], basket_id: basket_id})
      state = :sys.get_state(pid)
      :timer.sleep 50
      assert state.total == 311
    end
  end
end
