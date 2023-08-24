defmodule CumbucaWeb.SchemaTest do
  use CumbucaWeb.ConnCase, async: true

  import Cumbuca.AccountsFixtures
  import Cumbuca.TransactionsFixtures

  describe "login mutation" do
    @mutation """
    mutation Login($cpf: String!, $identifier: String!) {
      login(input: { cpf: $cpf, account_identifier: $identifier }) {
        token
      }
    }
    """

    test "should return invalid credentials on invalid params", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => @mutation,
          "variables" => %{cpf: "123", identifier: "123"}
        })

      assert %{"errors" => [error]} = json_response(conn, 200)
      assert error["status_code"] == 404
    end

    test "should return user info on valid params", %{conn: conn} do
      user = user_fixture()
      account = bank_account_fixture(user.id)

      conn =
        post(conn, "/api", %{
          "query" => @mutation,
          "variables" => %{cpf: user.cpf, identifier: account.identifier}
        })

      assert %{"data" => %{"login" => _}} = json_response(conn, 200)
    end
  end

  describe "check_balance query" do
    setup :register_and_generate_jwt_token

    @query """
    query CheckBalance {
      checkBalance
    }
    """

    test "should return the balance of current user", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => @query
        })

      assert %{"data" => %{"checkBalance" => "R$0.00"}} = json_response(conn, 200)
    end
  end

  describe "transactions query" do
    setup :register_and_generate_jwt_token

    setup ctx do
      user = user_fixture()
      account = bank_account_fixture(%{balance: Money.new(1000)}, user.id)

      transaction =
        transaction_fixture(account.identifier, ctx.account.identifier, %{
          amount: Money.new(10),
          processed_at: NaiveDateTime.utc_now()
        })

      yesterday = transaction.processed_at |> NaiveDateTime.add(-1, :day)
      tomorrow = transaction.processed_at |> NaiveDateTime.add(1, :day)

      query = """
      query Transactions {
      transactions(from_period: "#{yesterday}", to_period: "#{tomorrow}") {
          amount
        }
      }
      """

      Map.put(ctx, :query, query)
    end

    test "should return all transactions", %{conn: conn, query: query} do
      conn =
        post(conn, "/api", %{
          "query" => query
        })

      assert %{"data" => %{"transactions" => [_]}} = json_response(conn, 200)
    end
  end

  describe "transact mutation" do
    setup :register_and_generate_jwt_token

    @mutation """
    mutation RegisterTransaction($input: TransactInput!) {
      transact(input: $input) {
      identifier
      }
    }
    """

    test "should return a transaction id", %{conn: conn, account: receiver} do
      conn =
        post(conn, "/api", %{
          "query" => @mutation,
          "variables" => %{
            input: %{
              amount: 100,
              receiver: receiver.identifier
            }
          }
        })

      assert %{"data" => %{"transact" => %{"identifier" => _}}} = json_response(conn, 200)
    end
  end

  describe "chargeback_transaction mutation" do
    setup :register_and_generate_jwt_token

    setup ctx do
      user = user_fixture()
      account = bank_account_fixture(%{balance: Money.new(1000)}, user.id)

      transaction =
        transaction_fixture(account.identifier, ctx.account.identifier, %{amount: Money.new(10)})

      mutation = """
      mutation {
      chargebackTransaction(identifier: "#{transaction.identifier}") {
        identifier
        }
      }
      """

      Map.put(ctx, :mutation, mutation)
    end

    test "should return a transaction id", %{conn: conn, mutation: mutation} do
      conn = post(conn, "/api", %{"query" => mutation})

      assert %{"data" => %{"chargebackTransaction" => %{"identifier" => _}}} =
               json_response(conn, 200)
    end
  end
end
