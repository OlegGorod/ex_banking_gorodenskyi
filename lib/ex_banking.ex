defmodule ExBanking do
  use Application

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
         new_balance <- GenServer.call(user_pid, {:get_balance, currency}) do
      new_balance
    else
      [] -> {:error, :user_does_not_exist}
      {:error, reason} -> {:error, reason}
    end
  end

  def deposit(user, amount, currency) do
    with [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user) do
      GenServer.call(user_pid, {:deposit, amount, currency})
    else
      [] -> {:error, :user_does_not_exist}
    end
  end

  def withdraw(user, amount, currency) do
    with [{user_pid, _value}] <- Registry.lookup(Registry.ExBanking, user) do
      GenServer.call(user_pid, {:withdraw, amount, currency})
    else
      [] -> {:error, :user_does_not_exist}
    end
  end
end
