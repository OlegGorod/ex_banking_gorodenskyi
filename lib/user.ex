defmodule ExBanking.User do
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, %{}, name: {:via, Registry, {Registry.ExBanking, user_name}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_balance, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:deposit, amount, currency}, _, state) do
    new_state = Map.update(state,currency,amount, fn value -> value + amount end)
    {:reply, new_state, new_state}
  end

end
