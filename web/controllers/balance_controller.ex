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

    balance = Enum.reduce(operations, D.new(0), fn(op, total) -> Decimal.add(op.amount, total) end)

    conn
    |> render("show.json", balance)
  end

  def get_statement(conn, %{"account" => account, "start_at" => start_at, "end_at" => end_at}) do
    {account_num, _} = Integer.parse account
    {_, start_at} = Timex.parse start_at, "{YYYY}-{0M}-{0D}"
    {_, end_at} = Timex.parse end_at, "{YYYY}-{0M}-{0D}"

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_num,
      where: op.done_at >= ^start_at,
      where: op.done_at <= ^end_at,
      order_by: op.done_at
    )

    conn
    |> render("show_statement.json")
  end
end
