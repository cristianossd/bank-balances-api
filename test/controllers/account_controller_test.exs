defmodule PhoenixDocker.AccountControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias PhoenixDocker.Router
  alias PhoenixDocker.Repo
  alias PhoenixDocker.Operation
  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PhoenixDocker.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(PhoenixDocker.Repo, {:shared, self()})
    :ok
  end

  @opts Router.init([])
  test 'get bank statement' do
    Repo.delete_all(
      from op in Operation
    )

    operations = [
      %Operation{account: 1, type: "deposit", amount: 1000.0, done_at: ~N[2017-10-15 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Amazon", amount: -3.34, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Uber", amount: -45.23, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "withdrawal", amount: -180.0, done_at: ~N[2017-10-17 00:00:00]}
    ]

    operations
    |> Enum.each(fn(op) -> Repo.insert! op end)

    params = %{start_at: "2017-10-15", end_at: "2017-10-17"}
    conn = conn(:get, "/api/account/1/statement", params)
    response = Router.call(conn, @opts)

    assert response.status == 200

    statement = Poison.decode! response.resp_body
    daily_statement = Enum.at(statement, 0)

    assert daily_statement["date"] == "15/10/2017"
    assert daily_statement["balance"] == "1000"
    assert length(statement) == 3
  end

  test 'get bank statement for invalid account and date period' do
    Repo.delete_all(
      from op in Operation
    )

    params = %{start_at: "2017-10-17", end_at: "2017-10-15"}
    conn = conn(:get, "/api/account/1/statement", params)
    response = Router.call(conn, @opts)

    assert response.status == 200

    statement = Poison.decode! response.resp_body
    assert length(statement) == 0
  end

  test 'get debt periods' do
    Repo.delete_all(
      from op in Operation
    )

    operations = [
      %Operation{account: 1, type: "deposit", amount: 1000.0, done_at: ~N[2017-10-15 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Amazon", amount: -3.34, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Uber", amount: -45.23, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "withdrawal", amount: -180.0, done_at: ~N[2017-10-17 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "flight ticket", amount: -800.0, done_at: ~N[2017-10-18 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "espresso", amount: -10.0, done_at: ~N[2017-10-22 00:00:00]},
      %Operation{account: 1, type: "deposit", amount: 100.0, done_at: ~N[2017-10-25 00:00:00]}
    ]

    operations
    |> Enum.each(fn(op) -> Repo.insert! op end)

    conn = conn(:get, "/api/account/1/debt-periods")
    response = Router.call(conn, @opts)

    assert response.status == 200

    periods = Poison.decode! response.resp_body
    period = Enum.at(periods, 0)

    assert period["start_date"] == "18/10/2017"
    assert period["principal"] == "28.57"
    assert period["end_date"] == "21/10/2017"
    assert length(periods) == 2
  end

  test 'get debt periods with negative balance' do
    Repo.delete_all(
      from op in Operation
    )

    operations = [
      %Operation{account: 1, type: "deposit", amount: 1000.0, done_at: ~N[2017-10-15 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Amazon", amount: -3.34, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Uber", amount: -45.23, done_at: ~N[2017-10-16 00:00:00]},
      %Operation{account: 1, type: "withdrawal", amount: -180.0, done_at: ~N[2017-10-17 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "flight ticket", amount: -800.0, done_at: ~N[2017-10-18 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "espresso", amount: -10.0, done_at: ~N[2017-10-22 00:00:00]},
      %Operation{account: 1, type: "deposit", amount: 100.0, done_at: ~N[2017-10-25 00:00:00]},
      %Operation{account: 1, type: "purchase", description: "Ebay", amount: -500.12, done_at: ~N[2017-10-29 00:00:00]},
    ]

    operations
    |> Enum.each(fn(op) -> Repo.insert! op end)

    conn = conn(:get, "/api/account/1/debt-periods")
    response = Router.call(conn, @opts)

    assert response.status == 200

    periods = Poison.decode! response.resp_body
    period =
      periods
      |> Enum.take(-1)
      |> Enum.at(0)

    assert period["end_date"] == nil
  end

  test 'get empty debt periods' do
    Repo.delete_all(
      from op in Operation
    )

    %Operation{account: 1, type: "deposit", amount: 1000.0, done_at: ~N[2017-10-15 00:00:00]}
    |> Repo.insert!

    conn = conn(:get, "/api/account/1/debt-periods")
    response = Router.call(conn, @opts)

    assert response.status == 200

    periods = Poison.decode! response.resp_body
    assert length(periods) == 0
  end

  test 'get debt periods of unknown account' do
    Repo.delete_all(
      from op in Operation
    )

    conn = conn(:get, "/api/account/1/debt-periods")
    response = Router.call(conn, @opts)

    assert response.status == 200

    periods = Poison.decode! response.resp_body
    assert length(periods) == 0
  end
end
