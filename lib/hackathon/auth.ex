defmodule Hackathon.Auth do
  use GenServer

  defstruct users: %{}, sessions: %{}

  def start_link(_opts) do
    case GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Sistema de autenticación iniciado")
        {:ok, pid}
      error -> error
    end
  end

  def authenticate(user_id, token) do
    GenServer.call(__MODULE__, {:authenticate, user_id, token})
  end

  def logout(user_id) do
    GenServer.cast(__MODULE__, {:logout, user_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:authenticate, user_id, _token}, _from, state) do
    session_id = "session_#{user_id}_#{:rand.uniform(1000000)}"
    new_sessions = Map.put(state.sessions, session_id, %{user_id: user_id, created_at: :os.system_time(:seconds)})
    new_state = %{state | sessions: new_sessions}
    IO.puts("Usuario #{user_id} autenticado")
    {:reply, {:ok, session_id}, new_state}
  end

  def handle_cast({:logout, user_id}, state) do
    new_sessions = state.sessions
    |> Enum.reject(fn {_session_id, session} -> session.user_id == user_id end)
    |> Map.new()

    new_state = %{state | sessions: new_sessions}
    IO.puts("Usuario #{user_id} cerró sesión")
    {:noreply, new_state}
  end
end
