defmodule Cumbuca.Transactions.TransactEventTest do
  use ExUnit.Case, async: true

  alias Cumbuca.Transactions.TransactEvent

  @moduletag :unit

  describe "parse!/1" do
    test "should raise on invalid params" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        TransactEvent.parse!(%{})
      end
    end

    test "should return a TransactEvent on valid params" do
      assert %TransactEvent{} =
               TransactEvent.parse!(%{
                 amount: Money.new(100),
                 sender_identifier: "123",
                 receiver_identifier: "321",
                 transaction_identifier: "456"
               })
    end
  end
end
