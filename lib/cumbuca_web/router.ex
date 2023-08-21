defmodule CumbucaWeb.Router do
  use CumbucaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CumbucaWeb do
    pipe_through :api
  end
end
