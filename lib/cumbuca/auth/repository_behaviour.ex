defmodule Cumbuca.Auth.RepositoryBehaviour do
  alias Cumbuca.Auth.Models.User
  alias Cumbuca.Repo

  @callback fetch_user(Repo.id()) :: {:ok, User.t()} | {:error, :not_found}
  @callback fetch_user_by_public_id(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback upsert_user(User.t(), map) :: Repo.changeset()
end
