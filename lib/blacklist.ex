defmodule Feeb.Blacklist do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Feeb.Blacklist)
  end

  def put(n) do
    GenServer.cast(__MODULE__, {:put, n})
  end

  def delete(n) do
    GenServer.cast(__MODULE__, {:delete, n})
  end

  def member?(n) do
    GenServer.call(__MODULE__, {:member?, n})
  end

  ## Server Callbacks

  def init([]) do
    {:ok, MapSet.new()}
  end

  def handle_cast({:put, n}, blacklist) do
    {:noreply, MapSet.put(blacklist, n)}
  end

  def handle_cast({:delete, n}, blacklist) do
    {:noreply, MapSet.delete(blacklist, n)}
  end

  def handle_call({:member?, n}, _from, blacklist) do
    {:reply, MapSet.member?(blacklist, n), blacklist}
  end
end
