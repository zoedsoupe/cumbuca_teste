defmodule CumbucaWeb.Socket do
  @moduledoc "Socket to handle Absinthe subscriptions"

  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: CumbucaWeb.Schema

  alias Cumbuca.Accounts

  @token_salt "user authentication"
  @day_seconds 86_400
  @endpoint CumbucaWeb.Endpoint

  @impl true
  def connect(params, socket) do
    {:ok,
     Absinthe.Phoenix.Socket.put_options(socket,
       context: %{current_user: get_current_user(params)}
     )}
  end

  defp get_current_user(%{"Authorization" => bearer}) do
    [_, token] = String.split(bearer, ~r/\s/)

    with {:ok, user_id} <-
           Phoenix.Token.verify(@endpoint, @token_salt, token, max_age: @day_seconds),
         {:ok, user} <- Accounts.retrieve_user(user_id) do
      user
    end
  end

  @impl true
  def id(_socket), do: nil
end
