defmodule CumbucaWeb.Error do
  @moduledoc "Convert applications errors to Absinthe errors and externalize them"

  require Logger
  alias __MODULE__

  @fields ~w(code message status_code key)a

  @enforce_keys ~w(code message status_code)a
  defstruct @fields

  def normalize(err) do
    handle(err)
  end

  defp handle(errors) when is_list(errors) do
    Enum.map(errors, &handle/1)
  end

  defp handle(code) when is_atom(code) do
    {status, message} = metadata(code)

    %Error{code: code, message: message, status_code: status}
  end

  defp handle(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {key, error} ->
      %Error{
        code: :validation,
        message: error,
        status_code: 422,
        key: key
      }
    end)
  end

  defp handle(other) do
    Logger.error("Unhandled error term:\n#{inspect(other)}")
    handle(:unknown)
  end

  # Metadata
  # --------

  defp metadata(:unauthenticated), do: {401, "You need to make login first"}
  defp metadata(:invalid_credentials), do: {401, "Invalid Credentials"}
  defp metadata(:unauthorized), do: {403, "You are not authorized to perform this action"}
  defp metadata(:not_found), do: {404, "Resource not found"}
  defp metadata(:unknown), do: {500, "Something went wrong"}

  defp metadata(code) do
    Logger.warning("Unhandled error code: #{inspect(code)}")
    {422, to_string(code)}
  end
end
