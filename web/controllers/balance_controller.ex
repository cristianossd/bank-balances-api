defmodule PhoenixDocker.BalanceController do
  use PhoenixDocker.Web, :controller

  alias PhoenixDocker.Operation
  alias Decimal, as: D

  plug :scrub_params, "account" when action in [:show]

  def show(conn, %{"account" => account}) do
    {account_number, _} = Integer.parse account

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_number,
      order_by: op.done_at
    )

    balance = Enum.reduce(operations, D.new(0), fn(op, total) -> Decimal.add(op.amount, total) end)

    conn
    |> render("show.json", balance)
  end
end
