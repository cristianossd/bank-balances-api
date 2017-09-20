defmodule PhoenixDocker.Operation do
  use PhoenixDocker.Web, :model

  schema "operations" do
    field :account, :integer
    field :type, :string
    field :description, :string
    field :amount, :decimal
    field :done_at, :naive_datetime

    timestamps()
  end

  @required_fields ~w(account type amount done_at)
  @optional_fields ~w(description)
  @valid_types ~w(purchase withdrawal debit deposit salary credit)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_types
  end

  defp validate_types(model) do
    type = get_field(model, :type)

    validate_types(model, type)
  end

  defp validate_types(model, type) do
    if (Enum.member?(@valid_types, type)), do: model, else: add_error(model, :type, "Invalid type")
  end
end
