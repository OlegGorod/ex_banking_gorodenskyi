defmodule ExBanking.UserSupervisor do
  use DynamicSupervisor

  alias ExBanking.User

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_user(user_name) do
    DynamicSupervisor.start_child(__MODULE__, {User, user_name})
  end
end
