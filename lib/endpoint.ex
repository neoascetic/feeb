defmodule Feeb.Endpoint do
  require Logger

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  
  get "/list/:n" do
    conn_params = Plug.Conn.fetch_query_params(conn)
    next_key_s = Map.get(conn_params.query_params, "next_key", 0)
    size_s = Map.get(conn_params.query_params, "size", 100)
    case {validate_num(n), validate_num(next_key_s), validate_num(size_s)} do
      {{:ok, i}, {:ok, next_key}, {:ok, size}} ->
        gen_limit = min(i, next_key - 1 + size)
        Logger.info(
            "Requested #{size} items starting with #{next_key}; " <>
            "generating up to #{gen_limit}")
        full = Feeb.fiblist(gen_limit)
        slice = Enum.slice(full, next_key, size)
        response0 =
          case gen_limit do
            ^i -> %{}
            _ -> %{next_key: gen_limit + 1}
          end
        response1 = Map.merge(response0, %{result: slice})
        respond(conn_params, 200, response1)
      {:error, _, _} ->
        respond(conn_params, 400, %{error: "#{n} is invalid number"})
      {_, :error, _} ->
        respond(conn_params, 400, %{error: "#{next_key_s} is invalid number"})
      {_, _, :error} ->
        respond(conn_params, 400, %{error: "#{size_s} is invalid number"})
    end
  end

  get "/:n" do
    case validate_num(n) do
      {:ok, i} ->
        respond(conn, 200, %{result: Feeb.fib(i)})
      :error ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  match _ do
    respond(conn, 404, %{error: "not found"})
  end

  # internal stuff

  defp validate_num(n) when is_integer(n) and n >= 0 do
    {:ok, n}
  end

  defp validate_num(n) do
    case Integer.parse(n) do
      {i, ""} when i >= 0 -> {:ok, i}
      _ -> :error
    end
  end

  defp respond(conn, code, data) do
    {:ok, result} = JSON.encode(data)
    newconn = Plug.Conn.put_resp_header(conn, "Content-Type", "application/json")
    send_resp(newconn, code, result)
  end
end
