defmodule ElChatWeb.UserChannel do
  use Phoenix.Channel
  alias ElChat.{Repo, Message}
  import Ecto.Query, only: [from: 2]

  def join("user:" <> user_id, _info, socket) do
    if socket.assigns.user_id == user_id do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    users = from(m in Message,
      where: (m.opponent_id == ^socket.assigns.user_id and m.is_delivered == false),
      select: m.user_id,
      distinct: true)
      |> Repo.all
    push socket, "init:usr", %{users: users}
    {:noreply, socket}
  end
end
