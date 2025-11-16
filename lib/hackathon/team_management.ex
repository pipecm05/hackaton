defmodule Hackathon.TeamManagement do
  use GenServer

  defstruct teams: %{}, participants: %{}, team_participants: %{}

  # API Pública
  def start_link(_opts) do
    IO.puts("Iniciando gestión de equipos...")
    case GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Gestión de equipos iniciada")
        {:ok, pid}
      error ->
        IO.puts("Error en gestión de equipos: #{inspect(error)}")
        error
    end
  end

  def register_participant(id, name, email) do
    GenServer.call(__MODULE__, {:register_participant, id, name, email})
  end

  def create_team(team_id, team_name, creator_id, category) do
    GenServer.call(__MODULE__, {:create_team, team_id, team_name, creator_id, category})
  end

  def join_team(participant_id, team_id) do
    GenServer.call(__MODULE__, {:join_team, participant_id, team_id})
  end

  def list_teams do
    GenServer.call(__MODULE__, :list_teams)
  end

  def list_teams_by_category(category) do
    GenServer.call(__MODULE__, {:list_teams_by_category, category})
  end

  def get_team(team_id) do
    GenServer.call(__MODULE__, {:get_team, team_id})
  end

  # Callbacks del GenServer
  def init(state) do
    {:ok, state}
  end

  def handle_call({:register_participant, id, name, email}, _from, state) do
    participant = %{id: id, name: name, email: email, joined_at: :os.system_time(:seconds)}
    new_participants = Map.put(state.participants, id, participant)
    new_state = %{state | participants: new_participants}
    IO.puts("Participante registrado: #{name}")
    {:reply, {:ok, participant}, new_state}
  end

  def handle_call({:create_team, team_id, team_name, creator_id, category}, _from, state) do
    case Map.get(state.participants, creator_id) do
      nil ->
        {:reply, {:error, "Participante no encontrado"}, state}

      _creator ->
        team = %{
          id: team_id,
          name: team_name,
          creator_id: creator_id,
          category: category,
          created_at: :os.system_time(:seconds),
          status: :active,
          participants: [creator_id]
        }

        new_teams = Map.put(state.teams, team_id, team)
        new_team_participants = Map.put(state.team_participants, team_id, [creator_id])

        new_state = %{state |
          teams: new_teams,
          team_participants: new_team_participants
        }

        IO.puts("Equipo creado: #{team_name} en categoría #{category}")
        {:reply, {:ok, team}, new_state}
    end
  end

  def handle_call({:join_team, participant_id, team_id}, _from, state) do
    with %{} <- Map.get(state.participants, participant_id),
         %{} = team <- Map.get(state.teams, team_id),
         true <- team.status == :active do

      current_participants = Map.get(state.team_participants, team_id, [])

      if participant_id in current_participants do
        {:reply, {:error, "Ya estás en este equipo"}, state}
      else
        updated_participants = [participant_id | current_participants]
        updated_team = Map.put(team, :participant_count, length(updated_participants))

        new_teams = Map.put(state.teams, team_id, updated_team)
        new_team_participants = Map.put(state.team_participants, team_id, updated_participants)

        new_state = %{state |
          teams: new_teams,
          team_participants: new_team_participants
        }

        participant = Map.get(state.participants, participant_id)
        IO.puts("#{participant.name} se unió al equipo #{team.name}")
        {:reply, {:ok, updated_team}, new_state}
      end
    else
      nil -> {:reply, {:error, "Participante o equipo no encontrado"}, state}
      _ -> {:reply, {:error, "Equipo no activo"}, state}
    end
  end

  def handle_call(:list_teams, _from, state) do
    active_teams = state.teams
    |> Map.values()
    |> Enum.filter(fn team -> team.status == :active end)
    |> Enum.map(fn team ->
      participant_count = length(Map.get(state.team_participants, team.id, []))
      Map.put(team, :participant_count, participant_count)
    end)

    {:reply, {:ok, active_teams}, state}
  end

  def handle_call({:list_teams_by_category, category}, _from, state) do
    teams = state.teams
    |> Map.values()
    |> Enum.filter(fn team ->
      team.category == category and team.status == :active
    end)
    |> Enum.map(fn team ->
      participant_count = length(Map.get(state.team_participants, team.id, []))
      Map.put(team, :participant_count, participant_count)
    end)

    {:reply, {:ok, teams}, state}
  end

  def handle_call({:get_team, team_id}, _from, state) do
    case Map.get(state.teams, team_id) do
      nil -> {:reply, {:error, "Equipo no encontrado"}, state}
      team ->
        participants = Map.get(state.team_participants, team_id, [])
        |> Enum.map(fn pid -> Map.get(state.participants, pid) end)
        |> Enum.filter(fn p -> p != nil end)

        team_with_participants = Map.put(team, :participants, participants)
        {:reply, {:ok, team_with_participants}, state}
    end
  end
end
