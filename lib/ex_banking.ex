defmodule ExBanking do
  use Application

  alias ExBanking.TypesError
  alias ExBanking.{UserSupervisor, Validation}

  def start(_type, _args) do
    ExBanking.Supervisor.start_link([])
  end

  @spec create_user(user :: String.t()) :: :ok | TypesError.error_tuple()
  def create_user(user) do
    with true <- Validation.validate_args?(user),
         [] <- Registry.lookup(Registry.ExBanking, user) do
      UserSupervisor.add_user(user)
      :ok
    else
      false -> {:error, :wrong_arguments}
      [{_user_pid, _state}] -> {:error, :user_already_exists}
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | TypesError.error_tuple()
  def get_balance(user, currency) do
    with true <- Validation.validate_args?(user, currency),
         [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         response <- GenServer.call(user_pid, {:get_balance, currency}) do
      send(user_pid, {:operation_completed})
      response
    else
      false -> {:error, :wrong_arguments}
      [] -> {:error, :user_does_not_exist}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | TypesError.error_tuple()
  def deposit(user, amount, currency) do
    with true <- Validation.validate_args?(user, amount, currency),
         [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         {:ok, _} = result <- GenServer.call(user_pid, {:deposit, amount, currency}) do
      send(user_pid, {:operation_completed})
      result
    else
      false -> {:error, :wrong_arguments}
      [] -> {:error, :user_does_not_exist}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | TypesError.error_tuple()
  def withdraw(user, amount, currency) do
    with true <- Validation.validate_args?(user, amount, currency),
         [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user),
         %{} = new_state <- GenServer.call(user_pid, {:withdraw, amount, currency}) do
      send(user_pid, {:operation_completed})

      Validation.get_balance_validate(new_state, currency)
    else
      false -> {:error, :wrong_arguments}
      [] -> {:error, :user_does_not_exist}
      :not_enough_money -> {:error, :not_enough_money}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | TypesError.error_tuple()
  def send(from_user, to_user, amount, currency) do
    with true <- Validation.validate_args?(from_user, to_user, amount, currency),
         [{from_user_pid, to_user_pid}] <- Validation.existence_of_two_users(from_user, to_user),
         %{} = new_state <- GenServer.call(from_user_pid, {:withdraw, amount, currency}),
         {:ok, leftover_to_user} <- GenServer.call(to_user_pid, {:deposit, amount, currency}) do
      leftover_from_user = Map.get(new_state, currency)
      {:ok, leftover_from_user, leftover_to_user}
    else
      false -> {:error, :wrong_arguments}
      {:error, reason} -> {:error, reason}
      :not_enough_money -> {:error, :not_enough_money}
      :too_many_requests_to_user -> {:error, :too_many_requests_to_user}
    end
  end
end
