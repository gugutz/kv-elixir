defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given options
  
  :name is always required.
  """
  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end
  
  
  @doc """
  Looks up the bucket pid for 'name' stored in 'server'.

  Returns '{:ok, pid}' if the bucket exists, ':error' otherwise.
  """
  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without acessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
   
    # GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given 'name' in 'server'.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end


  ## Server Callbacks

  def init(table) do
    # 3. here we replace the names map by the ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true]) 
    refs = %{}
    {:ok, {names, refs}}
  end

  # 4. this function is now obsolete since lookups are done directly on the client API
  # def handle_call({:lookup, name}, _from, {names, _} = state) do
  #   {:reply, Map.fetch(names, name), state}
  # end

  def handle_call({:create, name}, _from, {names, refs}) do
    # 5. read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, pid} ->
        {:noreply, pid, {names, refs}}
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        # names = Map.put(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end
  

  def handle_info({:DOWN, ref, :process, _pid_, _reason}, {names, refs}) do
    # 6. delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    # names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
  
end


