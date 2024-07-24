defmodule ExBanking.User do
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, user_name, name: {:via, Registry, {Registry.ExBanking, user_name}})
  end

  def init(state) do
    {:ok, state}
  end
end
