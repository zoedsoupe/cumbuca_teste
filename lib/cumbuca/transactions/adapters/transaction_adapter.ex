defmodule Cumbuca.Transactions.TransactionAdapter do
  @moduledoc "Adapter to externalize the Transaction model"

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Models.User
  alias Cumbuca.Accounts.UserAccountAdapter
  alias Cumbuca.Transactions.Models.Transaction
  alias Cumbuca.Transactions.Schemas.AccountTransaction

  @typep internal_params :: %{
           transaction: Transaction.t(),
           sender: %{
             user: User.t(),
             bank_account: BankAccount.t()
           },
           receiver: %{
             user: User.t(),
             bank_account: BankAccount.t()
           }
         }

  @spec internal_to_external(internal_params) :: AccountTransaction.t()
  def internal_to_external(%{transaction: transaction} = params) do
    %{sender: sender, receiver: receiver} = params

    AccountTransaction.parse!(%{
      amount: Money.to_string(transaction.amount),
      processed_at: maybe_naive_date_time(transaction.processed_at),
      chargebacked_at: maybe_naive_date_time(transaction.chargebacked_at),
      sender: UserAccountAdapter.internal_to_external(sender),
      receiver: UserAccountAdapter.internal_to_external(receiver)
    })
  end

  defp maybe_naive_date_time(%NaiveDateTime{} = naive) do
    NaiveDateTime.to_iso8601(naive)
  end

  defp maybe_naive_date_time(nil), do: nil

  @spec external_to_internal(Cumbuca.Transactions.transact_params()) ::
          {:ok, Transaction.t()} | {:error, Cumbuca.Repo.changeset()}
  def external_to_internal(params) do
    params = %{
      amount: Money.new(params[:amount]),
      sender_id: params[:sender],
      receiver_id: params[:receiver]
    }

    %Transaction{}
    |> Transaction.changeset(params)
    |> Ecto.Changeset.apply_action(:parse)
  end
end
