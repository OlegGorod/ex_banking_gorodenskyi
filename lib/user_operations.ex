defmodule ExBanking.UserOperations do
  def substract(value, amount) when is_float(amount) or is_float(value) do
    Float.round(value - amount)
  end

  def substract(value, amount) do
    value - amount
  end

  def add(value, amount) when is_float(amount) or is_float(value) do
    Float.round(value + amount)
  end

  def add(value, amount) do
    value + amount
  end
end
