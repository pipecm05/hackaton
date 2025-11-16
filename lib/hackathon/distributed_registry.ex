# lib/hackathon/distributed_registry.ex
defmodule Hackathon.DistributedRegistry do
  use GenServer

  defstruct nodes: %{}, services: %{}, load_metrics: %{}

  def start_link(_opts) do
    IO.puts("Iniciando registro distribuido...")
    case GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Registro distribuido iniciado")
        {:ok, pid}
      error -> error
    end
  end

  def register_node(node_name, capabilities) do
    GenServer.cast(__MODULE__, {:register_node, node_name, capabilities})
  end

  def find_available_node(service) do
    GenServer.call(__MODULE__, {:find_available_node, service})
  end

  def init(state) do
    # Registrar nodo local
    local_capabilities = [:team_management, :project_registry, :chat, :mentorship]
    new_nodes = Map.put(state.nodes, :local, %{
      capabilities: local_capabilities,
      joined_at: :os.system_time(:seconds),
      status: :active,
      load: 0
    })

    IO.puts("Nodo local registrado con capacidades: #{inspect(local_capabilities)}")
    {:ok, %{state | nodes: new_nodes}}
  end

  def handle_cast({:register_node, node_name, capabilities}, state) do
    node_info = %{
      capabilities: capabilities,
      joined_at: :os.system_time(:seconds),
      status: :active,
      load: 0
    }

    new_nodes = Map.put(state.nodes, node_name, node_info)
    new_state = %{state | nodes: new_nodes}
    IO.puts("Nodo #{node_name} registrado con capacidades: #{inspect(capabilities)}")
    {:noreply, new_state}
  end

  def handle_call({:find_available_node, service}, _from, state) do
    available_node = state.nodes
    |> Enum.filter(fn {_node_name, info} ->
      service in info.capabilities and info.status == :active and info.load < 80
    end)
    |> Enum.min_by(fn {_node_name, info} -> info.load end, fn -> nil end)

    case available_node do
      {node_name, info} ->
        updated_info = Map.put(info, :load, info.load + 10)
        new_nodes = Map.put(state.nodes, node_name, updated_info)
        new_state = %{state | nodes: new_nodes}
        IO.puts("Nodo #{node_name} seleccionado para servicio: #{service}")
        {:reply, {:ok, node_name}, new_state}
      nil ->
        IO.puts(" No hay nodos disponibles para el servicio: #{service}")
        {:reply, {:error, :no_available_nodes}, state}
    end
  end
end
