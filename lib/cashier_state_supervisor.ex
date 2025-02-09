defmodule CashierStateSupervisor do
  use DynamicSupervisor

  def start_link([name]) do
    DynamicSupervisor.start_link(__MODULE__, name: name || generate_random_string())
  end

  def start_child({_module, []}) do
   DynamicSupervisor.start_child(__MODULE__, {CashierState, [generate_random_string()]})
  end

  def start_child({_module, name: name}) do
    DynamicSupervisor.start_child(__MODULE__, {CashierState, [name || generate_random_string()]})
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp generate_random_string() do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64()
    |> String.replace(~r/[-_\=]/, "")
    |> Kernel.binary_part(0, 32)
    |> String.to_atom()
  end
end
