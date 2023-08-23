defmodule Cumbuca.Repo.Migrations.CreateBankAccountTable do
  use Ecto.Migration

  def change do
    create table(:bank_account) do
      add(:identifier, :string, null: false)
      add(:balance, :map, null: false)
      add(:user_id, references(:user, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:bank_account, [:user_id]))
    create unique_index(:bank_account, [:identifier])
  end
end
