defmodule Cumbuca.Transactions.TransactionLogic do
  @moduledoc "Validation logic for Transaction"

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Transactions.Models.Transaction

  @spec check_if_was_chargebacked(Transaction.t()) :: {:ok, atom} | {:error, atom}
  def check_if_was_chargebacked(%Transaction{} = transaction) do
    if transaction.chargebacked_at do
      {:error, :already_chargebacked}
    else
      {:ok, :can_be_chargebacked}
    end
  end

  @spec validate_transaction(BankAccount.t(), BankAccount.t(), Money.t()) :: :ok | {:error, atom}
  def validate_transaction(sender, receiver, amount) do
    cond do
      !sender or !receiver or !amount -> {:error, :invalid_params}
      sender.id == receiver.id -> {:error, :same_account}
      Money.cmp(sender.balance, amount) == :lt -> {:error, :insufficient_funds}
      true -> :ok
    end
  end
end
