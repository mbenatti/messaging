defmodule Messaging.API.MessagingController do
  use Phoenix.Controller


  def create(conn, %{"queue" => queue, "message" => message}) do

    conn
    |> put_status(200)
    |> json(%{message: "Message Received!"})
  end

  def create(conn, _) do

    conn
    |> put_status(400)
    |> json(%{message: "invalid params, query params accepted: 'queue' and 'message'"})
  end
end