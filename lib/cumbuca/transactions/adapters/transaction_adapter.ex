defmodule Cumbuca.Transactions.TransactionAdapter do
  @moduledoc "Adapter to externalize the Transaction model"

  alias Cumbuca.Accounts.Schemas.UserAccount
  alias Cumbuca.Transactions.Models.Transaction
  alias Cumbuca.Transactions.Schemas.AccountTransaction

  @typep internal_params :: %{
           transaction: Transaction.t(),
           sender: UserAccount.t(),
           receiver: UserAccount.t()
         }

  @spec internal_to_external(internal_params) :: AccountTransaction.t()
  def internal_to_external(%{transaction: transaction} = params) do
    %{sender: sender, receiver: receiver} = params

    AccountTransaction.parse!(%{
      amount: Money.to_string(transaction.amount),
      processed_at: NaiveDateTime.to_iso8601(transaction.processed_at),
      sender: sender,
      receiver: receiver
    })
  end

  @spec external_to_new_internal(Cumbuca.Transactions.transact_params()) :: map
  def external_to_new_internal(params) do
    %{
      type: :transfer,
      amount: Money.new(params[:amount]),
      sender_id: params[:sender],
      receiver_id: params[:receiver]
    }
  end
end
