defmodule Hackathon.MentorshipSystem do
  use GenServer

  defstruct mentors: %{}, team_mentors: %{}, feedback_history: %{}, inquiries: %{}

  def start_link(_opts) do
    IO.puts("Iniciando sistema de mentoría...")
    case GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Sistema de mentoría iniciado")
        {:ok, pid}
      error -> error
    end
  end

  def register_mentor(mentor_id, name, expertise) do
    GenServer.call(__MODULE__, {:register_mentor, mentor_id, name, expertise})
  end

  def assign_mentor_to_team(team_id, mentor_id) do
    GenServer.call(__MODULE__, {:assign_mentor_to_team, team_id, mentor_id})
  end

  def send_inquiry(team_id, question) do
    GenServer.cast(__MODULE__, {:send_inquiry, team_id, question})
  end

  def send_feedback(mentor_id, team_id, feedback) do
    GenServer.call(__MODULE__, {:send_feedback, mentor_id, team_id, feedback})
  end

  def get_team_feedback(team_id) do
    GenServer.call(__MODULE__, {:get_team_feedback, team_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:register_mentor, mentor_id, name, expertise}, _from, state) do
    mentor = %{
      id: mentor_id,
      name: name,
      expertise: expertise,
      registered_at: :os.system_time(:seconds),
      status: :active
    }

    new_mentors = Map.put(state.mentors, mentor_id, mentor)
    new_state = %{state | mentors: new_mentors}
    IO.puts("Mentor registrado: #{name} - #{inspect(expertise)}")
    {:reply, {:ok, mentor}, new_state}
  end

  def handle_call({:assign_mentor_to_team, team_id, mentor_id}, _from, state) do
    with %{} <- Map.get(state.mentors, mentor_id),
         true <- Map.get(state.mentors, mentor_id).status == :active do

      new_team_mentors = Map.put(state.team_mentors, team_id, mentor_id)
      new_state = %{state | team_mentors: new_team_mentors}
      mentor = Map.get(state.mentors, mentor_id)
      IO.puts("Mentor #{mentor.name} asignado al equipo #{team_id}")
      {:reply, {:ok, :assigned}, new_state}
    else
      _ -> {:reply, {:error, "Mentor no disponible"}, state}
    end
  end

  def handle_call({:send_feedback, mentor_id, team_id, feedback}, _from, state) do
    feedback_record = %{
      id: "feedback_#{:rand.uniform(1000000)}",
      mentor_id: mentor_id,
      team_id: team_id,
      feedback: feedback,
      timestamp: :os.system_time(:seconds)
    }

    team_feedback = Map.get(state.feedback_history, team_id, [])
    updated_feedback = [feedback_record | team_feedback]
    new_feedback_history = Map.put(state.feedback_history, team_id, updated_feedback)

    new_state = %{state | feedback_history: new_feedback_history}
    mentor = Map.get(state.mentors, mentor_id)
    IO.puts("Feedback de #{mentor.name} para equipo #{team_id}")
    {:reply, {:ok, feedback_record}, new_state}
  end

  def handle_call({:get_team_feedback, team_id}, _from, state) do
    feedback = Map.get(state.feedback_history, team_id, [])
    |> Enum.sort_by(& &1.timestamp)

    {:reply, {:ok, feedback}, state}
  end

  def handle_cast({:send_inquiry, team_id, question}, state) do
    _inquiry = %{
    team_id: team_id,
    question: question,
    timestamp: :os.system_time(:seconds),
    status: :pending
  }

    case Map.get(state.team_mentors, team_id) do
      nil ->
        IO.puts("Consulta del equipo #{team_id}: #{question} (buscando mentores disponibles)")
      mentor_id ->
        mentor = Map.get(state.mentors, mentor_id)
        IO.puts("Consulta del equipo #{team_id} para mentor #{mentor.name}: #{question}")
    end

    {:noreply, state}
  end
end
