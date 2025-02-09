defmodule CashierState do
  use Agent
  require Logger

  def start_link([name]= initial_value) do
    Agent.start_link(fn -> initial_value end, name: name)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  def update(new_value) do
    Agent.update(__MODULE__, fn _state -> new_value end)
  end
end
