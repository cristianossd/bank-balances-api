defmodule PhoenixDocker.OperationController do
  require Logger
  use PhoenixDocker.Web, :controller

  alias PhoenixDocker.Operation

  def create(conn, params) do
    date = ~N[2017-05-10 10:10:10]
    amount = if (is_debit? params["type"]), do: params["amount"] * -1, else: params["amount"]

    operation = %Operation{
      account: params["account"],
      type: params["type"],
      description: params["description"],
      amount: amount,
      date: date
    }

    {:ok, _} = Repo.insert(operation)
    json conn, :ok
  end

  def is_debit? type do
    types = ["purchase", "withdrawal", "debit"]

    len = length(Enum.filter(types, fn(t) -> t == type end))
    len > 0
  end
end
