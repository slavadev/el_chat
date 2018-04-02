defmodule ElChatWeb.ChatChannel do
  use Phoenix.Channel
  alias ElChat.{Repo,Message}
  import Ecto.Query, only: [from: 2]

  def join("chat:" <> users_string, _info, socket) do
    if users_string |> String.split(":") |> Enum.member?(socket.assigns.user_id) do
      send(self(), :after_join)
      {:ok, %{}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    room = String.replace_prefix(socket.topic, "chat:", "")
    messages = Repo.all(from m in Message, where: m.room == ^room, order_by: m.id)
      |> Enum.map(fn m -> Map.take(m, [:id, :user_id, :sent_at, :text]) end)
    push socket, "init:msg", %{messages: messages}
    Presence.track(socket, socket.assigns.user_id, %{})
    {:noreply, socket}
  end

  def handle_in("new:msg", msg, socket) do
    opponent_id = socket.topic
      |> String.replace_prefix("chat:", "")
      |> String.split(":")
      |> List.delete(socket.assigns.user_id)
      |> List.first
    changes = %{room: String.replace_prefix(socket.topic, "chat:", ""),
                user_id: socket.assigns.user_id,
                opponent_id: opponent_id,
                text: msg,
                sent_at: DateTime.utc_now,
                is_delivered: false
               }
    case Message.changeset(%Message{}, changes) |> Repo.insert do
      {:ok, message} ->
        broadcast! socket, "new:msg", Map.take(message, [:id, :user_id, :text, :sent_at])
        if Enum.count(Presence.list(socket)) == 1 do
          ElChatWeb.Endpoint.broadcast!("user:#{opponent_id}", "new:msg", %{user_id: socket.assigns.user_id})
        end
      {:error, _changeset} -> nil
    end
    {:reply, :ok, socket}
  end

  def handle_in("read:msg", id, socket) do
    room = String.replace_prefix(socket.topic, "chat:", "")
    from(m in Message, where: m.room == ^room and m.opponent_id == ^socket.assigns.user_id and m.id <= ^id)
    |> Repo.update_all(set: [is_delivered: true])
    {:noreply, socket}
  end
end