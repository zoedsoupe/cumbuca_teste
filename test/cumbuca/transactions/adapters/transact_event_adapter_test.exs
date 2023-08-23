defmodule Cumbuca.Transactions.TransactEventAdapterTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Transactions.TransactEvent
  alias Cumbuca.Transactions.TransactEventAdapter

  @moduletag :unit

  describe "external_to_internal/1" do
    test "should return raise on invalid params" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        TransactEventAdapter.external_to_internal(%{})
      end
    end

    test "should return a TransactEvent on valid params" do
      assert %TransactEvent{} =
               TransactEventAdapter.external_to_internal(%{
                 "sender_id" => "sender_id",
                 "receiver_id" => "receiver_id",
                 "amount" => Money.new(100),
                 "identifier" => "identifier"
               })
    end
  end
end
