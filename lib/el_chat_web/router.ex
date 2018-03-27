defmodule ElChatWeb.Router do
  use ElChatWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElChatWeb do
    pipe_through :api
  end
end
