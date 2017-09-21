defmodule PhoenixDocker.BalanceControllerTest do
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
  test 'get current balance' do
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

    conn = conn(:get, "/api/balance/1")
    response = Router.call(conn, @opts)

    assert response.status == 200
    assert (response.resp_body |> Poison.decode!)["balance"] == "771.43"
  end

  test 'get balance of unknown account' do
    conn = conn(:get, "/api/balance/1212")
    response = Router.call(conn, @opts)

    assert response.status == 200
    assert (response.resp_body |> Poison.decode!)["balance"] == "0"
  end
end
