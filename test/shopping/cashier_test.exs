defmodule CashierTest do
  use ExUnit.Case
  alias Shopping.Cashier

  setup do
    Application.stop(:shopping)
    :ok = Application.start(:shopping)
    :ok
  end

  test "updates state with the right total when given a valid product list" do
    {:ok, pid} = Cashier.start
    basket_id = :rand.uniform(9999999999999999)
    :ok = Cashier.calculate_total(pid, %{items: [:GR1,:GR1], basket_id: basket_id})
    state = :sys.get_state(pid)
    :timer.sleep 50
    assert state.total == 311
  end

  #TODO
  #test "throws function clause error when given an invalid params" do
  #  {:ok, pid} = Cashier.start
    # assert_raise KeyError, fn ->
    #   Cashier.total(pid, ["oops"])
    # end
    # assert catch_exit(Cashier.total(pid, ["oops"])) ==
    # #  {:exit, %KeyError{key: "oops", term: %{GR1: 311, SR1: 500, CF1: 1123}}}
    # {
    #   {{:badkey, "oops"}, [{:erlang, :map_get, ["oops", %{GR1: 311, SR1: 500, CF1: 1123}], [error_info: %{module: :erl_erts_errors}]}, {Shopping, :get_price!, 1, [file: ~c"lib/shopping.ex", line: 75]}, {Shopping.Cashier, :handle_call, 3, [file: ~c"lib/shopping/cashier.ex", line: 45]}, {:gen_server, :try_handle_call, 4, [file: ~c"gen_server.erl", line: 1113]}, {:gen_server, :handle_msg, 6, [file: ~c"gen_server.erl", line: 1142]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 241]}]},
    #   {GenServer, :call, [pid, {:total, {%{}, ["oops"]}}, 5000]}
    # }

  #end

  #TODO - restarts if Cashier terminates
  # test "stores state when it terminates" do
  #   {:ok, state_pid_2} = CashierStateSupervisor.start_child({CashierState, name: String.to_atom("CashierState293")})
  #   {:ok, pid} = CashierSupervisor.start_child({Cashier, [[:CF1], state_pid_2]})
  #   GenServer.call(pid, :total)

  #   GenServer.stop(pid)
  #   state = CashierState.get(state_pid_2)
  #   assert Map.get(state, :processed) == %{CF1: {1,1123}}
  # end
end
