defmodule ElChat.Message do
  use Ecto.Schema
  import Ecto.Changeset


  schema "messages" do
    field :is_delivered, :boolean, default: false
    field :opponent_id, :integer
    field :room, :string
    field :sent_at, :naive_datetime
    field :text, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:room, :text, :user_id, :opponent_id, :sent_at, :is_delivered])
    |> validate_required([:room, :text, :user_id, :opponent_id, :sent_at, :is_delivered])
  end
end
