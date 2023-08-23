defmodule Cumbuca.Accounts do
  @moduledoc "Context to interact with user accounts"

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Repository
  alias Cumbuca.Accounts.UserAccountAdapter
  alias Cumbuca.Repo

  @opaque public_id :: String.t()

  @spec register_user_account(map) ::
          {:ok, UserAccount.t()} | {:error, Repo.changeset()}
  def register_user_account(params) do
    case Repository.create_user_account_transaction(params) do
      {:ok, models} -> {:ok, UserAccountAdapter.internal_to_external(models)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec retrieve_user_account(public_id) :: {:ok, UserAccount.t()} | {:error, :not_found}
  def retrieve_user_account(account_ident) do
    with {:ok, models} <- Repository.fetch_bank_account(account_ident) do
      {:ok, UserAccountAdapter.internal_to_external(models)}
    end
  end

  @spec retrieve_bank_account(public_id) :: {:ok, BankAccount.t()} | {:error, :not_found}
  def retrieve_bank_account(account_ident) do
    with {:ok, user_account} <- Repository.fetch_bank_account(account_ident) do
      {:ok, user_account.bank_account}
    end
  end

  @spec retrieve_user(public_id) :: {:ok, User.t()} | {:error, :not_found}
  def retrieve_user(user_ident) do
    Repository.fetch_user_by_public_id(user_ident)
  end

  @spec transfer_amount_between_accounts(BankAccount.t(), BankAccount.t(), Money.t()) ::
          {:ok, :done} | :error
  def transfer_amount_between_accounts(sender, receiver, amount) do
    sender_attrs = withdrawl_amount(sender, amount)
    receiver_attrs = deposit_amount(receiver, amount)

    Repository.update_accounts_balance_transaction(sender, receiver, sender_attrs, receiver_attrs)
  end

  defp withdrawl_amount(%BankAccount{} = sender, amount) do
    sender
    |> Map.from_struct()
    |> Map.update(:balance, sender.balance, &Money.subtract(&1, amount))
  end

  defp deposit_amount(%BankAccount{} = receiver, amount) do
    receiver
    |> Map.from_struct()
    |> Map.update(:balance, receiver.balance, &Money.add(&1, amount))
  end
end
