defmodule CumbucaWeb.Router do
  use CumbucaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CumbucaWeb.Context
  end

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: CumbucaWeb.Schema,
    socket: CumbucaWeb.UserSocket

  scope "/api" do
    pipe_through :api
    forward "/", Absinthe.Plug, schema: CumbucaWeb.Schema
  end
end
