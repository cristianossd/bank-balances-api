defmodule PhoenixDocker.BalanceController do
  use PhoenixDocker.Web, :controller

  alias PhoenixDocker.Operation
  alias Decimal, as: D

  plug :scrub_params, "account" when action in [:show, :get_statement]
  plug :scrub_params, "start_at" when action in [:get_statement]
  plug :scrub_params, "end_at" when action in [:get_statement]

  def show(conn, %{"account" => account}) do
    {account_num, _} = Integer.parse account

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_num,
      order_by: op.done_at
    )

    balance = calculate_balance operations

    conn
    |> render("show.json", balance)
  end

  defp calculate_balance operations do
    Enum.reduce(operations, D.new(0), fn(op, total) -> D.add(op.amount, total) end)
  end
end
