defmodule CumbucaWeb.Middlewares.EnsureAuthentication do
  @moduledoc "Ensure that the user is authenticated"

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [put_result: 2]

  def call(resolution, _) do
    case resolution.context do
      %{current_user: _} -> resolution
      _ -> put_result(resolution, {:error, :unauthenticated})
    end
  end
end
