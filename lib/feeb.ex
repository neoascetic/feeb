defmodule Feeb do
  require Logger

  @moduledoc """
  Documentation for `Feeb`.

  TODO: add a big precompiled map of the Fibonacci numbers to save calclulation time,
  do the actual calculation only if the requested item is bigger that the size of this
  cache; optionally cache new things there in a separate gen_server
  """

  @doc """
  Get Fibonacci number.
  Takes into account if the number is blacklisted.

  ## Examples

      iex> Feeb.fib(6)
      {:ok, 8}
      iex> Feeb.put_to_blacklist(6)
      :ok
      iex> Feeb.fib(6)
      {:error, :blacklisted}
      iex> Feeb.delete_from_blacklist(6)
      :ok

  """

  def fib(n) when n >= 0 do
    case Feeb.Blacklist.member?(n) do
      true ->
        Logger.warning("Someone tried to get the prohibited value of #{n}!")
        {:error, :blacklisted}
      false ->
        [f|_] = calc_fiblist(n)
        {:ok, f}
    end
  end


  @doc """
  List all Fibonacci numbers until the given.
  Takes into account if the number is blacklisted.

  ## Examples

      iex> Feeb.fiblist(6)
      [0, 1, 1, 2, 3, 5, 8]
      iex> Feeb.put_to_blacklist(2)
      :ok
      iex> Feeb.fiblist(6)
      [0, 1, 2, 3, 5, 8]
      iex> Feeb.delete_from_blacklist(2)
      :ok

  """
  def fiblist(n) when n >= 0 do
    list = calc_fiblist(n)
    filter_and_reverse(list, n, [])
  end


  @doc """
  Put a number to blacklist to hide from the results.

  ## Examples

      iex> Feeb.put_to_blacklist(42)
      :ok

  """
  def put_to_blacklist(n) do
    Logger.info("Blacklisting #{n}")
    Feeb.Blacklist.put(n)
  end


  @doc """
  Delete a number from blacklist to show again in the results.

  ## Examples

      iex> Feeb.delete_from_blacklist(42)
      :ok

  """
  def delete_from_blacklist(n) do
    Logger.info("Unblacklisting #{n}")
    Feeb.Blacklist.delete(n)
  end


  # internal functions

  defp filter_and_reverse([], _n, acc) do acc end
  defp filter_and_reverse([head|tail], n, acc) do
    # depending on how we're tolerant to the consistency,
    # we could also first get the current state of the blacklist
    # and filter against it to not block the main blacklist
    newacc = 
      case Feeb.Blacklist.member?(n) do
        true -> acc
        false -> [head|acc]
      end
    filter_and_reverse(tail, n-1, newacc)
  end

  defp calc_fiblist(0) do [0] end
  defp calc_fiblist(n) do
    calc_fiblist(n-1, [1, 0])
  end

  defp calc_fiblist(0, acc) do acc end
  defp calc_fiblist(n, [n1, n2 | _tail]=acc) do
    calc_fiblist(n-1, [n1 + n2 | acc])
  end

end
