defmodule ExBanking.Validation do
  def get_balance_validate(state, currency) do
    balance = Map.get(state, currency)

    if balance do
      {:ok, balance}
    else
      {:ok, 0}
    end
  end

  def check_enough_money(state, amount, currency) do
    IO.inspect(state)
    balance = Map.get(state, currency)
    balance != nil && balance >= amount
  end

  def existence_of_two_users(from_user, to_user) do
    with [{from_user_pid, _value}] <- Registry.lookup(Registry.ExBanking, from_user),
         [{to_user_pid, _value}] <- Registry.lookup(Registry.ExBanking, to_user) do
      [{from_user_pid, to_user_pid}]
    else
      [] -> {:error, :user_does_not_exist}
    end
  end
end
