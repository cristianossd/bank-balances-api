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
end
