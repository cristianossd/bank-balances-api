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

    periods = []
    in_debt = false
    debt = %{}
    zero = D.new(0)

    Enum.reduce(operations, D.new(0), fn(op, total) ->
      balance = D.add(op.amount, total)

      if D.compare(balance, zero) == D.new(-1) and D.compare(balance, total) != zero and !in_debt do
        debt = Map.put_new(debt, :start_date, Timex.format!(op.done_at, "{0D}/{0M}/{YYYY}"))
        debt = Map.put_new(debt, :principal, balance)
        in_debt = true
      else
        if D.compare(balance, total) != zero and in_debt do
          day_before = Timex.shift op.done_at, days: -1
          not_in_debt_date = Timex.format! op.done_at, "{0D}/{0M}/{YYYY}"
          debt = Map.put_new(debt, :end_date, Timex.format!(day_before, "{0D}/{0M}/{YYYY}"))

          if debt.start_date != not_in_debt_date do
            periods ++ debt
          end

          debt = Map.put(debt, :start_date, nil)
          debt = Map.put(debt, :end_date, nil)
          debt = Map.put(debt, :principal, nil)
          in_debt = false

          if D.compare(balance, zero) == D.new(-1) do
            debt = Map.put(debt, :start_date, not_in_debt_date)
            debt = Map.put(debt, :principal, balance)
            in_debt = true
          end
        end
      end

      if (op == Enum.at(operations, -1)) do
        periods ++ debt
      end

      balance
    end)

    conn
    |> json periods
  end
end
