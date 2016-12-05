defmodule AzaleaExample do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(AzaleaExample.Repo, []),
      Plug.Adapters.Cowboy.child_spec(:http, Site, [], [port: 4000])
    ]

    opts = [strategy: :one_for_one, name: AzaleaExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
