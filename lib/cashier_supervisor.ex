defmodule CashierSupervisor do
  use DynamicSupervisor

  def start_link([name]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: name)
  end

  def start_child({_module, [products, state_pid]}) do
   DynamicSupervisor.start_child(__MODULE__, {Cashier, [products, state_pid]})
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
