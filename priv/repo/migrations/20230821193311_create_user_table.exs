defmodule Cumbuca.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:user) do
      add :cpf, :citext, null: false
      add :first_name, :string, null: false
      add :last_name, :string
      add :public_id, :string, null: false

      timestamps()
    end

    create unique_index(:user, [:cpf])
  end
end
