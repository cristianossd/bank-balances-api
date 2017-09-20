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
      in_debt = if (D.compare(balance, D.new(0)) == D.new(-1)), do: true, else: false

      {%{start_date: start_date, principal: balance, in_debt: in_debt}, balance}
    end)

    {periods, _} = Enum.map_reduce(Enum.reverse(periods), :empty, fn(period, date) ->
      formatted_day_before = nil

      if date != :empty do
        {_, date} = Timex.parse date, "{0D}/{0M}/{YYYY}"
        day_before = Timex.shift date, days: -1
        formatted_day_before = Timex.format! day_before, "{0D}/{0M}/{YYYY}"
      end

      period = Map.put_new(period, :end_date, formatted_day_before)

      {period, period.start_date}
    end)

    periods = Enum.reverse(periods)
    debt_periods =
      periods
      |> Enum.filter(fn(period) -> period.in_debt end)
      |> Enum.map(fn(period) -> Map.delete(period, :in_debt) end)

    conn
    |> json(debt_periods)
  end
end
