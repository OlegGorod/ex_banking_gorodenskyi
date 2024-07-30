defmodule ExBanking.User do
  alias ExBanking.Validation
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, %{"operations_count" => 0}, name: {:via, Registry, {Registry.ExBanking, user_name}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_balance, currency}, _from, state) do
    if state["operations_count"] < 10 do
      response = Validation.get_balance_validate(state, currency)
      new_state = Map.update!(state, "operations_count", &(&1 +1))
      {:reply, response, new_state}
    else
      {:reply, :too_many_requests_to_user, state}
    end
  end

  def handle_call({:deposit, amount, currency}, _, state) do
    if state["operations_count"] < 10 do
      new_state = Map.update(state, currency, amount, fn value -> value + amount end)
      response = Validation.get_balance_validate(new_state, currency)
      new_state = Map.update!(new_state, "operations_count", &(&1 +1))
      {:reply, response, new_state}
    else
      {:reply, :too_many_requests_to_user, state}
    end
  end

  def handle_call({:withdraw, amount, currency}, _, state) do
    with true <- Validation.check_enough_money(state, amount, currency) do
      new_state = Map.update(state, currency, amount, fn value -> value - amount end)
      {:reply, new_state, new_state}
    else
      false -> {:reply, :not_enough_money, state}
    end
  end

  def handle_info({:operation_completed}, state) do
    new_state = Map.update!(state, "operations_count", &(&1 - 1))
    {:noreply, new_state}
  end
end
