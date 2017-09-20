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

  def get_statement(conn, %{"account" => account, "start_at" => start_at, "end_at" => end_at}) do
    {account_num, _} = Integer.parse account
    {_, start_at} = Timex.parse start_at, "{YYYY}-{0M}-{0D}"
    {_, end_at} = Timex.parse end_at, "{YYYY}-{0M}-{0D}"

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_num,
      where: op.done_at < ^start_at,
      order_by: op.done_at
    )

    prev_balance = if (length(operations) == 0), do: D.new(0), else: calculate_balance(operations)

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_num,
      where: op.done_at >= ^start_at,
      where: op.done_at <= ^end_at,
      order_by: op.done_at
    )

    {statement, _} =
      operations
      |> Enum.group_by(fn(op) -> op.done_at end)
      |> Enum.map_reduce(prev_balance, fn({date, group}, balance_acc) ->
          {balance_acc, new_statement} = get_daily_statement(date, group, balance_acc)
          {new_statement, balance_acc}
         end)

    conn
    |> json statement
  end

  defp calculate_balance operations do
    Enum.reduce(operations, D.new(0), fn(op, total) -> D.add(op.amount, total) end)
  end

  defp get_daily_statement date, operations, balance do
    formatted_date = Timex.format! date, "{0D}/{0M}/{YYYY}"

    daily_operations = Enum.map(operations, fn(op) ->
      zero = D.new(0)
      negative = D.new(-1)

      amount = if (op.amount < zero), do: op.amount * negative, else: op.amount
      %{description: op.description, amount: amount}
    end)

    balance = Enum.reduce(operations, balance, fn(op, total) -> D.add(op.amount, total) end)
    daily_statement = %{
      date: formatted_date,
      operations: daily_operations,
      balance: balance
    }

    {balance, daily_statement}
  end
end
