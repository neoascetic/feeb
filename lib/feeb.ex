defmodule Feeb do
  @moduledoc """
  Documentation for `Feeb`.

  TODO: add a big precompiled map of the Fibonacci numbers to save calclulation time,
  do the actual calculation only if the requested item is bigger that the size of this
  cache; optionally cache new things there in a separate gen_server
  """

  @doc """
  Get Fibonacci number.

  ## Examples

      iex> Feeb.fib(5)
      8

  """

  def fib(n) when n >= 0 do
    [f|_] = calc_fiblist(n)
    f
  end


  @doc """
  List all Fibonacci numbers until the given.

  ## Examples

      iex> Feeb.fiblist(6)
      [0, 1, 1, 2, 3, 5, 8]

  """
  def fiblist(n) when n >= 0 do
    Enum.reverse(calc_fiblist(n))
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
