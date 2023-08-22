defmodule Cumbuca.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add :amount, :map, null: false
      add :identifier, :string, null: false
      add :processed_at, :naive_datetime, null: false

      add :sender_id, references(:bank_account, on_delete: :nothing)
      add :receiver_id, references(:bank_account, on_delete: :nothing)

      timestamps()
    end

    create index(:transaction, [:sender_id])
    create index(:transaction, [:receiver_id])
  end
end
