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
    balance = Map.get(state, currency)
    balance != nil && balance >= amount
  end

  def existence_of_two_users(from_user, to_user) do
    from_user_pid = Registry.lookup(Registry.ExBanking, from_user)
    to_user_pid = Registry.lookup(Registry.ExBanking, to_user)

    cond do
      from_user_pid == [] ->
        {:error, :sender_does_not_exist}

      to_user_pid == [] ->
        {:error, :receiver_does_not_exist}

      true ->
        [{from_user_pid, _}] = from_user_pid
        [{to_user_pid, _}] = to_user_pid
        [{from_user_pid, to_user_pid}]
    end
  end
end
