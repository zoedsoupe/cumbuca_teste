defmodule CumbucaWeb.Schema do
  @moduledoc "Main Absinthe GraphQL schema"

  # use Absinthe.Schema

  alias CumbucaWeb.Middlewares

  def middleware(middleware, _field, _object) do
    middleware ++ [Middlewares.EnsureAuthentication, Middlewares.ErrorHandler]
  end
end
