defmodule Feeb.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Feeb.Endpoint.init([])

  test "input validation" do
    {code, response} = request(:get, "/asd6")
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}

    {code, response} = request(:get, "/list/asd6")
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}

    {code, response} = request(:get, "/list/6", %{next_key: "asd6"})
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}

    {code, response} = request(:get, "/list/6", %{size: "asd6"})
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}

    {code, response} = request(:put, "/blacklist/asd6")
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}

    {code, response} = request(:delete, "/blacklist/asd6")
    assert code == 400
    assert response == %{"error" => "asd6 is invalid number"}
  end

  test "it returns correct value for get" do
    {code, response} = request(:get, "/6")
    assert code == 200
    assert response == %{"result" => 8}
  end

  test "it returns correct value for list" do
    {code, response} = request(:get, "/list/6")
    assert code == 200
    assert response == %{"result" => [0, 1, 1, 2, 3, 5, 8]}
  end

  test "it returns correct value for list with pagination" do
    {code, response} = request(:get, "/list/6", %{size: "2"})
    assert code == 200
    assert response == %{"result" => [0, 1], "next_key" => 2}

    {code, response} = request(:get, "/list/6", %{size: "2", next_key: "2"})
    assert code == 200
    assert response == %{"result" => [1, 2], "next_key" => 4}

    {code, response} = request(:get, "/list/6", %{size: "2", next_key: "6"})
    assert code == 200
    assert response == %{"result" => [8]}
  end

  test "test blacklist workflow" do
    {code, response} = request(:put, "/blacklist/2")
    assert code == 204
    {code, response} = request(:put, "/blacklist/6")
    assert code == 204

    {code, response} = request(:get, "/2")
    assert code == 403
    assert response == %{"error" => "blacklisted"}

    {code, response} = request(:get, "/6")
    assert code == 403
    assert response == %{"error" => "blacklisted"}

    {code, response} = request(:get, "/list/6")
    assert code == 200
    # 2nd and 6th are missing
    assert response == %{"result" => [0, 1, 2, 3, 5]}

    {code, response} = request(:delete, "/blacklist/6")
    assert code == 204
    {code, response} = request(:get, "/6")
    assert code == 200
    assert response == %{"result" => 8}

    {code, response} = request(:get, "/list/6")
    assert code == 200
    # 2nd still missing
    assert response == %{"result" => [0, 1, 2, 3, 5, 8]}
  end

  defp request(method, path, query \\ %{}) do
    conn = conn(method, path, query)
    conn = Feeb.Endpoint.call(conn, @opts)
    assert Enum.member?(conn.resp_headers, {"content-type", "application/json"})
    assert conn.state == :sent

    response =
      case JSON.decode(conn.resp_body) do
        {:ok, decoded} -> decoded
        {:error, _} -> ""
      end

    {conn.status, response}
  end
end
