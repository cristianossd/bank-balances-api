defmodule PhoenixDocker.OperationControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias PhoenixDocker.Router


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PhoenixDocker.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(PhoenixDocker.Repo, {:shared, self()})
    :ok
  end

  @opts Router.init([])
  test 'connect to API' do
    conn = conn(:get, "/api/")
    response = Router.call(conn, @opts)

    assert response.status == 200
  end

  test 'insert operations' do
    operation = %{account: 1001, type: "deposit", amount: 1000.0, done_at: "2017-10-15"}

    conn = conn(:post, "/api/operations", operation)
    response = Router.call(conn, @opts)

    assert response.status == 201
  end

  test 'insert invalid operation' do
    operation = %{account: :empty, type: :empty, amount: :empty, done_at: "2017-10-15"}

    conn = conn(:post, "/api/operations", operation)
    response = Router.call(conn, @opts)

    assert response.status != 201
  end

  test 'insert non integer account' do
    operation = %{account: "1001ab", type: "purchase", amount: -38.2, done_at: "2017-10-15"}

    conn = conn(:post, "/api/operations", operation)
    response = Router.call(conn, @opts)

    assert response.status != 201
  end

  test 'insert op with invalid type' do
    operation = %{account: 1001, type: "transfer", amount: -38.2, done_at: "2017-10-15"}

    conn = conn(:post, "/api/operations", operation)
    response = Router.call(conn, @opts)

    assert response.status != 201
  end
end
