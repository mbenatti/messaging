defmodule Mix.Tasks.Samples do
  @moduledoc """
  Samples of 1000 messages in 50 queues using 30 as concurrency factor
  """
  use Mix.Task

  @queues Enum.map(1..50, fn n -> "#{n}" end)
  @messages ["message-sample", "email.com", "message-sample-2", "any-other-message"]

  @impl Mix.Task
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:httpoison)

    IO.puts("Enqueuing")

    1..1_000
    |> Task.async_stream(
      fn _ ->
        enqueue()
      end,
      max_concurrency: 30
    )
    |> Stream.run()

    IO.puts("Enqueue finished")
  end

  defp enqueue do
    message = Enum.random(@messages)
    queue = Enum.random(@queues)

    HTTPoison.get("http://localhost:4000/receive-message?queue=#{queue}&message=#{message}")
  end
end
