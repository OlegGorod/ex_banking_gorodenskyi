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
end
