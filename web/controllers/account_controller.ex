defmodule PhoenixDocker.AccountController do
  use PhoenixDocker.Web, :controller

  alias PhoenixDocker.Operation
  alias Decimal, as: D

  plug :scrub_params, "account" when action in [:get_debt_periods]

  def get_debt_periods(conn, %{"account" => account}) do
    {account_num, _} = Integer.parse account

    operations = Repo.all(
      from op in Operation,
      where: op.account == ^account_num,
      order_by: op.done_at
    )

    days = Enum.group_by(operations, fn(op) -> op.done_at end)
    {periods, balance} = Enum.map_reduce(days, D.new(0), fn({date, daily_operations}, total) ->
      balance = Enum.reduce(daily_operations, total, fn(op, acc) -> D.add(op.amount, total) end)

      start_date = Timex.format! date, "{0D}/{0M}/{YYYY}"
      in_debt = false
      if D.compare(balance, D.new(0)) == D.new(-1) do
        in_debt = true
      end

      {%{start_date: start_date, principal: balance, in_debt: in_debt}, balance}
    end)

    conn
    |> json(periods)
  end
end
