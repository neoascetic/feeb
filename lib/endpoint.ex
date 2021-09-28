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
            "generating up to #{gen_limit}"
        )

        full = Feeb.fiblist(gen_limit)
        page = Enum.slice(full, next_key, size)
        response = maybe_add_next_key(i, gen_limit, %{result: page})
        respond(conn_params, 200, response)

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
        case Feeb.fib(i) do
          {:ok, fib} ->
            respond(conn, 200, %{result: fib})

          {:error, :blacklisted} ->
            respond(conn, 403, %{error: :blacklisted})
        end

      :error ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  put "/blacklist/:n" do
    case validate_num(n) do
      {:ok, i} ->
        :ok = Feeb.put_to_blacklist(i)
        respond(conn, 204)

      :error ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  delete "/blacklist/:n" do
    case validate_num(n) do
      {:ok, i} ->
        :ok = Feeb.delete_from_blacklist(i)
        respond(conn, 204)

      :error ->
        respond(conn, 400, %{error: "#{n} is invalid number"})
    end
  end

  match _ do
    respond(conn, 404, %{error: "not found"})
  end

  # internal stuff

  defp maybe_add_next_key(max, max, acc) do
    acc
  end

  defp maybe_add_next_key(_max, gen_limit, acc) do
    Map.merge(acc, %{next_key: gen_limit + 1})
  end

  defp validate_num(n) when is_integer(n) and n >= 0 do
    {:ok, n}
  end

  defp validate_num(n) do
    case Integer.parse(n) do
      {i, ""} when i >= 0 -> {:ok, i}
      _ -> :error
    end
  end

  defp respond(conn, code, data \\ nil) do
    newconn = Plug.Conn.put_resp_header(conn, "content-type", "application/json")
    send_resp(newconn, code, maybe_encode_result(data))
  end

  defp maybe_encode_result(nil) do
    ""
  end

  defp maybe_encode_result(data) do
    {:ok, result} = JSON.encode(data)
    result
  end
end
