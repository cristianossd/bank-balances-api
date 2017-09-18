defmodule PhoenixDocker.Router do
  use PhoenixDocker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixDocker do
    pipe_through :api

    # operations
    get "/", OperationController, :index
    post "/operations", OperationController, :create

    # balance
    get "/balance/:account", BalanceController, :show
    get "/balance/:account/statement", BalanceController, :get_statement
  end
end
