defmodule PhoenixDocker.Operation do
  use PhoenixDocker.Web, :model

  schema "operations" do
    field :account, :integer
    field :type, :string
    field :description, :string
    field :amount, :decimal
    field :date, :naive_datetime

    timestamps
  end
end
