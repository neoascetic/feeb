defmodule Feeb.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Feeb.Endpoint,
        options: [port: Application.get_env(:feeb, :port)]
      ),
      {Feeb.Blacklist, []}
    ]

    opts = [strategy: :one_for_one, name: Feeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
