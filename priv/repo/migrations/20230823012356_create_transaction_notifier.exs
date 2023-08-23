defmodule Cumbuca.Repo.Migrations.CreateTransactionNotifier do
  use Ecto.Migration

  def up do
    execute """
    CREATE FUNCTION notify_transaction_processment() RETURNS trigger AS $$
    DECLARE
      payload RECORD;
    BEGIN
      SELECT amount, sender_id,
      receiver_id, identifier
      INTO payload
      FROM transaction AS t
      ORDER BY t.inserted_at DESC;

      PERFORM pg_notify(
        'process_transaction',
        json_build_object('payload', payload)::text
      );

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
    """

    execute """
    CREATE TRIGGER transaction_created AFTER INSERT
    ON transaction
    FOR EACH ROW
    EXECUTE PROCEDURE notify_transaction_processment();
    """
  end

  def down do
    execute "DROP TRIGGER IF EXISTS transaction_created ON transaction;"
    execute "DROP FUNCTION IF EXISTS notify_transaction_processment;"
  end
end
