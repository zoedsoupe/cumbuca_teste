defmodule Cumbuca.Auth do
  @moduledoc """
  Entrypoint for the Auth context.
  Other contexts can only communicate with Auth via this module.
  """

  alias Cumbuca.Auth.Repository

  def create_user(params) do
    Repository.upsert_user(params)
  end
end
