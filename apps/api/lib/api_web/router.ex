defmodule Messaging.APIWeb.Router do
  use Messaging.APIWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Messaging.APIWeb do
    pipe_through :api

    get "/receive-message", MessagingController, :create
  end
end
