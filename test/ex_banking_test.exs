defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking
  import ExBanking

  setup do
    :ok = Application.stop(:ex_banking)
    :ok = Application.start(:ex_banking)
    :ok
  end

  test "create user" do
    assert create_user("Mark") == :ok
  end

  test "create existing user" do
    assert create_user("Mark") == :ok
    assert create_user("Mark") == {:error, :user_already_exists}
  end

  test "get balance of nonexistent user" do
    assert get_balance("Mark", "$") == {:error, :user_does_not_exist}
  end

  test "get balance" do
    create_user("Mark")
    deposit("Mark", 100, "$")
    assert get_balance("Mark", "$") == {:ok, 100}
  end

  test "put deposit" do
    create_user("Mark")
    assert deposit("Mark", 100, "$") == {:ok, 100}
  end

  test "withdraw an amount over than has user" do
    create_user("Mark")
    deposit("Mark", 100, "$")
    assert withdraw("Mark", 200, "$") == {:error, :not_enough_money}
  end

  test "withdraw an amount of nonexistent user" do
    assert withdraw("Mark", 200, "$") == {:error, :user_does_not_exist}
  end

  test "send amount from one user to another" do
    create_user("Mark")
    create_user("Andrew")
    deposit("Mark", 100, "$")
    leftover_mark_deposit = 0
    assert send("Mark", "Andrew", 100, "$") == {:ok, leftover_mark_deposit, 100}
  end

  test "send amount from one user to nonexistent receiver" do
    create_user("Mark")
    deposit("Mark", 100, "$")
    assert send("Mark", "Andrew", 100, "$") == {:error, :receiver_does_not_exist}
  end
end
