defmodule CumbucaWeb.Middlewares.EnsureAuthentication do
  @moduledoc "Ensure that the user is authenticated"

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [path: 1, put_result: 2]

  def call(resolution, _) do
    path = Enum.filter(path(resolution), &(&1 == "login"))

    case {resolution.context, path} do
      {_ctx, ["login"]} -> resolution
      {%{current_user: _}, _path} -> resolution
      {_ctx, _path} -> put_result(resolution, {:error, :unauthenticated})
    end
  end
end
