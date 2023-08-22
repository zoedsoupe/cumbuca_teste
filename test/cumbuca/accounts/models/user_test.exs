defmodule Cumbuca.Accounts.Models.UserTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Accounts.Models.User

  @moduletag :unit

  describe "changeset/2" do
    @invalid_params %{cpf: 123, first_name: nil, last_name: 123}
    @missing_required_params %{last_name: "dummy"}
    @valid_params %{cpf: "90318175037", first_name: "dummy", last_name: "last"}
    @valid_user %User{cpf: "97962104287", first_name: "dummy", last_name: "last"}

    test "should return an error changeset on invalid params" do
      changeset = User.changeset(%User{}, @invalid_params)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert errors_on(changeset)[:cpf]
      assert errors_on(changeset)[:first_name]
      assert errors_on(changeset)[:last_name]
    end

    test "should return an error changset on missing required params" do
      changeset = User.changeset(%User{}, @missing_required_params)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert errors_on(changeset)[:cpf]
      assert errors_on(changeset)[:first_name]
      refute errors_on(changeset)[:last_name]
    end

    test "should return a valid changeset on valid params" do
      changeset = User.changeset(%User{}, @valid_params)

      assert %Ecto.Changeset{valid?: true} = changeset
      refute errors_on(changeset)[:cpf]
      refute errors_on(changeset)[:first_name]
      refute errors_on(changeset)[:last_name]
    end

    test "should return a valid changeset with new values on new chnages" do
      changeset = User.changeset(@valid_user, @valid_params)

      assert %Ecto.Changeset{valid?: true} = changeset
      assert @valid_params.cpf == changeset.changes[:cpf]
      refute errors_on(changeset)[:cpf]
      refute errors_on(changeset)[:first_name]
      refute errors_on(changeset)[:last_name]
    end
  end
end
