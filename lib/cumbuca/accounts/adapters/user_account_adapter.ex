defmodule Cumbuca.Accounts.UserAccountAdapter do
  @moduledoc "Adapter that converts internal models to a external schema"

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Models.User
  alias Cumbuca.Accounts.Schemas.UserAccount

  @opaque internal_user_account :: %{
            user: User.t(),
            bank_account: BankAccount.t()
          }

  @spec internal_to_external(internal_user_account) :: UserAccount.t()
  def internal_to_external(%{user: user, bank_account: bank_account}) do
    UserAccount.parse!(%{
      balance: Money.to_string(bank_account.balance),
      identifier: bank_account.identifier,
      owner_cpf: user.cpf,
      owner_first_name: user.first_name,
      owner_last_name: user.last_name
    })
  end
end
