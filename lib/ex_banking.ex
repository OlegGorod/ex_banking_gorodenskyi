defmodule ExBanking do
  use Application

  alias ExBanking.{UserSupervisor}

  def start(_type, _args) do
    ExBanking.Supervisor.start_link([])
  end

  def create_user(user) do
    UserSupervisor.add_user(user)
  end
end
