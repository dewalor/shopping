defmodule CashierSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child({_module, basket}) do
   DynamicSupervisor.start_child(__MODULE__, {Cashier, basket})
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
