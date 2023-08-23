defmodule CumbucaWeb.Context do
  @moduledoc "Put the current user on Absinthe context"

  @behaviour Plug

  import Plug.Conn

  alias Cumbuca.Accounts

  @token_salt "user authentication"
  @day_seconds 86_400
  @endpoint CumbucaWeb.Endpoint

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    with {:ok, user_id} <-
           Phoenix.Token.verify(@endpoint, @token_salt, token, max_age: @day_seconds) do
      Accounts.retrieve_user(user_id)
    end
  end
end
