defmodule CashierState do
  use Agent
  require Logger

  def start_link([name]) do
    Agent.start_link(fn -> %{processed: %{}, unprocessed: [], state_pid: self()} end, name: name)
  end

  def get(pid) do
    Agent.get(pid, fn state -> state end)
  end

  def update(pid, {processed, unprocessed, state_pid}) do
    Agent.update(pid, fn _state -> %{processed: processed, unprocessed: unprocessed, state_pid: state_pid} end)
  end
end
