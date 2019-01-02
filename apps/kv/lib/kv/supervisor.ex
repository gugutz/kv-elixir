defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  # here we pass the tuple containing the name of the Registry, and the Supervisor will automatically
  # start the name of the module given here (KV.Registry) and init the function `start_link` inside.
  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: KV.RouterTasks}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

end



