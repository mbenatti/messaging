defmodule Messaging.APIWeb.MessagingController do
  @moduledoc """
  Controller responsible to receive requests about receiving messages
  """

  use Messaging.APIWeb, :controller

  alias Messaging.Core.QueueManager

  @doc false
  def create(conn, %{"queue" => queue, "message" => message}) do
    :ok = QueueManager.enqueue(queue, message)

    conn
    |> put_status(200)
    |> json(%{message: "Message received!"})
  end

  @doc false
  def create(conn, _) do
    conn
    |> put_status(400)
    |> json(%{message: "Invalid params, query params accepted: 'queue' and 'message'"})
  end
end
