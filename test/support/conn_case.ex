defmodule CumbucaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CumbucaWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint CumbucaWeb.Endpoint

      use CumbucaWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CumbucaWeb.ConnCase
    end
  end

  setup tags do
    Cumbuca.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_and_generate_jwt_token(%{conn: conn}) do
    import Cumbuca.AccountsFixtures
    user = user_fixture()
    account = bank_account_fixture(user.id)
    token = Phoenix.Token.sign(CumbucaWeb.Endpoint, "user authentication", user.public_id)

    %{
      conn: Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token),
      user: user,
      account: account
    }
  end
end
