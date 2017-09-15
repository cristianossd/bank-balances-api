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

    post "/operations", OperationController, :create
  end
end
