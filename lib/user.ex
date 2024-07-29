defmodule ExBanking.User do
  alias ExBanking.Validation
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, %{}, name: {:via, Registry, {Registry.ExBanking, user_name}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_balance, currency}, _from, state) do
    new_state = Validation.get_balance_validate(state, currency)
    {:reply, new_state, state}
  end

  def handle_call({:deposit, amount, currency}, _, state) do
    new_state = Map.update(state, currency, amount, fn value -> value + amount end)
    response = Validation.get_balance_validate(new_state, currency)
    {:reply, response, new_state}
  end

  def handle_call({:withdraw, amount, currency}, _, state) do
    with true <- Validation.check_enough_money(state, amount, currency) do
      new_state = Map.update(state, currency, amount, fn value -> value - amount end)
      {:reply, new_state, new_state}
    else
      false -> {:reply, :not_enough_money, state}
    end
  end
end
