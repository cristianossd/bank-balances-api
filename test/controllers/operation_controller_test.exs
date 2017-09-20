defmodule PhoenixDocker.OperationControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias PhoenixDocker.Router

  @opts Router.init([])
  test 'connect to API' do
    conn = conn(:get, "/api/")
    response = Router.call(conn, @opts)

    assert response.status == 200
  end
end
