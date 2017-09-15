defmodule PhoenixDocker.Repo.Migrations.CreateOperation do
  use Ecto.Migration

  def change do
    create table(:operations) do
      add :account, :integer
      add :type, :string
      add :description, :string
      add :amount, :decimal
      add :date, :naive_datetime

      timestamps
    end

    create unique_index(:operations, [:account])
  end
end
