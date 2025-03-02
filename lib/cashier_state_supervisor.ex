defmodule CashierStateSupervisor do
  use DynamicSupervisor

  def start_link([name]) do
    DynamicSupervisor.start_link(__MODULE__, name: name || Shopping.generate_random_string())
  end

  def start_child({_module, []}) do
   DynamicSupervisor.start_child(__MODULE__, {CashierState, [Shopping.generate_random_string()]})
  end

  def start_child({_module, name: name}) do
    DynamicSupervisor.start_child(__MODULE__, {CashierState, [name || Shopping.generate_random_string()]})
  end

  def init(name: name) do
    DynamicSupervisor.init(name: name, strategy: :one_for_one)
  end
end
