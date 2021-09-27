defmodule Feeb.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  
  get "/list/:n" do
    case Integer.parse(n) do
      {i, ""} when i >= 0 ->
        respond(conn, 200, %{result: Feeb.fiblist(i)})
      _ ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  get "/:n" do
    case Integer.parse(n) do
      {i, ""} when i >= 0 ->
        respond(conn, 200, %{result: Feeb.fib(i)})
      _ ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  match _ do
    respond(conn, 404, %{error: "not found"})
  end


  defp respond(conn, code, data) do
    {:ok, result} = JSON.encode(data)
    newconn = Plug.Conn.put_resp_header(conn, "Content-Type", "application/json")
    send_resp(newconn, code, result)
  end
end
