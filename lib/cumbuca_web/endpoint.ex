defmodule CumbucaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :cumbuca
  use Absinthe.Phoenix.Endpoint

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :cumbuca
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  socket "/socket", CumbucaWeb.Socket, websocket: true, longpoll: false

  plug CumbucaWeb.Router
end
