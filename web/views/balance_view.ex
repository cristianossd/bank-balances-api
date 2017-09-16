defmodule PhoenixDocker.BalanceView do
  use PhoenixDocker.Web, :view

  def render("show.json", balance) do
    %{balance: balance}
  end
end
