defmodule CashierStateSupervisor do
  use DynamicSupervisor

  def start_link([name]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: name)
  end

  def start_child({_module, []}) do
   DynamicSupervisor.start_child(__MODULE__, {CashierState, [Shopping.generate_random_string()]})
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
