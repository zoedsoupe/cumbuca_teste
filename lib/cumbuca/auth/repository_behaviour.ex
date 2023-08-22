defmodule Cumbuca.Auth.RepositoryBehaviour do
  @moduledoc "Behaviour for Auth module repository funcitons"

  alias Auth.Models.User
  alias Cumbuca.Repo

  @callback fetch_user(Repo.id()) :: {:ok, User.t()} | {:error, :not_found}
  @callback fetch_user_by_public_id(id) :: {:ok, User.t()} | {:error, :not_found}
            when id: String.t()
  @callback upsert_user(User.t(), map) :: Repo.changeset()
end
