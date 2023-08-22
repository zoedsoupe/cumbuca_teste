defmodule Cumbuca.Auth.Repository do
  @moduledoc "Common Database management for Auth context"

  use Cumbuca, :repository

  alias Cumbuca.Auth.Models.User
  alias Cumbuca.Auth.RepositoryBehaviour

  @behaviour RepositoryBehaviour

  @impl true
  def fetch_user(id) do
    Repo.fetch_by(User, id: id)
  end

  @impl true
  def fetch_user_by_public_id(public_id) do
    Repo.fetch_by(User, public_id: public_id)
  end

  @impl true
  def upsert_user(user \\ %User{}, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
