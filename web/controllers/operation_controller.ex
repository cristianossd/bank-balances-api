defmodule PhoenixDocker.OperationController do
  use PhoenixDocker.Web, :controller

  alias PhoenixDocker.Operation

  plug :scrub_params, "account" when action in [:create]
  plug :scrub_params, "type" when action in [:create]
  plug :scrub_params, "amount" when action in [:create]
  plug :scrub_params, "done_at" when action in [:create]

  def index(conn, _) do
    render conn, "index.json"
  end

  def create(conn, params) do
    {_, done_at} = Timex.parse params["done_at"], "{YYYY}-{0M}-{0D}"

    amount = params["amount"]
    if amount < 0 or is_debit?(params["type"]) do
      amount = amount * -1
    end

    changeset = Operation.changeset(%Operation{}, %{
      account: params["account"],
      type: params["type"],
      description: params["description"],
      amount: amount,
      done_at: done_at
    })

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_status(:created)
        |> render("created.json")
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{reason: :error})
    end
  end

  defp is_debit? type do
    types = ["purchase", "withdrawal", "debit"]

    Enum.member?(types, type)
  end
end
