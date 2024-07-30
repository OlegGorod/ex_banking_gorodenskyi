defmodule ExBanking do
  use Application

  alias ExBanking.Validation
  alias ExBanking.{UserSupervisor}

  def start(_type, _args) do
    ExBanking.Supervisor.start_link([])
  end

  def create_user(user) do
    with [] <- Registry.lookup(Registry.ExBanking, user) do
      UserSupervisor.add_user(user)
      :ok
    else
      [{_user_pid, _state}] -> {:error, :user_already_exists}
    end
  end

  def get_balance(user, currency) do
    with [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         response <- GenServer.call(user_pid, {:get_balance, currency}) do
      send(user_pid, {:operation_completed})
      response
    else
      [] -> {:error, :user_does_not_exist}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end

  def deposit(user, amount, currency) do
    with [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         {:ok, _} = result <- GenServer.call(user_pid, {:deposit, amount, currency}) do
      send(user_pid, {:operation_completed})
      result
    else
      [] -> {:error, :user_does_not_exist}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end

  def withdraw(user, amount, currency) do
    with [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         %{} = new_state <- GenServer.call(user_pid, {:withdraw, amount, currency}) do
      send(user_pid, {:operation_completed})

      Validation.get_balance_validate(new_state, currency)
    else
      [] -> {:error, :user_does_not_exist}
      :not_enough_money -> {:error, :not_enough_money}
    end
  end

  def send(from_user, to_user, amount, currency) do
    with [{from_user_pid, to_user_pid}] <- Validation.existence_of_two_users(from_user, to_user),
         %{} = new_state <- GenServer.call(from_user_pid, {:withdraw, amount, currency}),
         {:ok, leftover_to_user} <- GenServer.call(to_user_pid, {:deposit, amount, currency}) do
      leftover_from_user = Map.get(new_state, currency)
      {:ok, leftover_from_user, leftover_to_user}
    else
      {:error, reason} -> {:error, reason}
      :not_enough_money -> {:error, :not_enough_money}
    end
  end
end
