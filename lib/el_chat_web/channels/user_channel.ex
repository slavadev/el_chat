defmodule ElChatWeb.UserChannel do
  use Phoenix.Channel

  def join("user:" <> user_id, _info, socket) do
    if socket.assigns.user_id == user_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end