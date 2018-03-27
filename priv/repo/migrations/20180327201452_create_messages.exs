defmodule ElChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration
  def change do
    create table(:messages) do
      add :room, :string, null: false
      add :text, :string, null: false
      add :user_id, :integer, null: false
      add :opponent_id, :integer, null: false
      add :sent_at, :naive_datetime, null: false
      add :is_delivered, :boolean, default: false, null: false
      timestamps()
    end
    create index(:messages, [:room])
    create index(:messages, [:opponent_id, :is_delivered])
    create index(:messages, [:opponent_id, :is_delivered, :id])
  end
end
