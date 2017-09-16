defmodule PhoenixDocker.Repo.Migrations.CreateOperation do
  use Ecto.Migration

  def change do
    create table(:operations) do
      add :account, :integer
      add :type, :string
      add :description, :string
      add :amount, :decimal
      add :done_at, :naive_datetime

      timestamps()
    end
  end
end
