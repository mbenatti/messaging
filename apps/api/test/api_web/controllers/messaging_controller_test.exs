defmodule Messaging.APIWeb.MessagingControllerTest do
  use Messaging.APIWeb.ConnCase, async: true

  @path "/receive-message"

  describe "receive message" do
    test "success", %{conn: conn} do
      %Plug.Conn{status: status, resp_body: resp} = get(conn, @path, %{"queue" => "my_queue", "message" => "my_msg"})

      %{"message" => resp_message} = Jason.decode!(resp)
      assert resp_message =~ "Message received!"
      assert status == 200
    end

    test "fail", %{conn: conn} do
      %Plug.Conn{status: status, resp_body: resp} = get(conn, @path)

      %{"message" => resp_message} = Jason.decode!(resp)
      assert resp_message =~ "Invalid params"
      refute status == 200
    end
  end

end