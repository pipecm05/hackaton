defmodule Hackathon.CommandHandler do
  use GenServer

  def start_link(_opts) do
    case GenServer.start_link(__MODULE__, %{}, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Manejador de comandos iniciado")
        {:ok, pid}
      error -> error
    end
  end

  def process_command(command, user_id) do
    GenServer.call(__MODULE__, {:process_command, command, user_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:process_command, command, user_id}, _from, state) do
    response = case parse_command(command) do
      {:teams} ->
        handle_teams_command()

      {:teams, category} when is_binary(category) ->
        handle_teams_by_category_command(category)

      {:project, team_name} ->
        handle_project_command(team_name)

      {:join, team_name} ->
        handle_join_command(team_name, user_id)

      {:chat, room_name} ->
        handle_chat_command(room_name, user_id)

      {:help} ->
        handle_help_command()

      {:unknown, cmd} ->
        "Comando desconocido: #{cmd}. Use /help para ver comandos disponibles."

      _ ->
        "Error procesando comando. Use /help para ayuda."
    end

    {:reply, response, state}
  end

  defp parse_command("/teams " <> category), do: {:teams, String.trim(category)}
  defp parse_command("/teams"), do: {:teams}
  defp parse_command("/project " <> team_name), do: {:project, String.trim(team_name)}
  defp parse_command("/join " <> team_name), do: {:join, String.trim(team_name)}
  defp parse_command("/chat " <> room_name), do: {:chat, String.trim(room_name)}
  defp parse_command("/help"), do: {:help}
  defp parse_command(cmd), do: {:unknown, cmd}

  defp handle_teams_command do
    case Hackathon.TeamManagement.list_teams() do
      {:ok, teams} ->
        teams
        |> Enum.map(&format_team/1)
        |> Enum.join("\n")
        |> wrap_response("Equipos activos:")

      {:error, reason} -> "Error: #{reason}"
    end
  end

  defp handle_teams_by_category_command(category) do
    case Hackathon.TeamManagement.list_teams_by_category(category) do
      {:ok, teams} ->
        teams
        |> Enum.map(&format_team/1)
        |> Enum.join("\n")
        |> wrap_response("Equipos en categoría #{category}:")

      {:error, reason} -> "Error: #{reason}"
    end
  end

  defp handle_project_command(team_name) do
    case Hackathon.ProjectRegistry.get_team_project(team_name) do
      {:ok, project} -> format_project_response(project)
      {:error, reason} -> "Error: #{reason}"
    end
  end

  defp handle_join_command(team_name, user_id) do
    case Hackathon.TeamManagement.join_team(user_id, team_name) do
      {:ok, team} -> "Te has unido al equipo: #{team.name}"
      {:error, reason} -> "Error: #{reason}"
    end
  end

  defp handle_chat_command(room_name, user_id) do
    case Hackathon.ChatSystem.join_room(room_name, user_id, get_user_name(user_id)) do
      {:ok, room} -> "Conectado a la sala: #{room.name} - #{room.topic}"
      {:error, reason} -> "Error: #{reason}"
    end
  end

  defp handle_help_command do
    """
    **Comandos disponibles:**

    `/teams` - Listar todos los equipos activos
    `/teams [categoría]` - Listar equipos por categoría
    `/project [nombre_equipo]` - Mostrar información del proyecto de un equipo
    `/join [nombre_equipo]` - Unirse a un equipo
    `/chat [sala]` - Ingresar al canal de chat
    `/help` - Mostrar esta ayuda

    **Ejemplos:**
    `/teams IA` - Listar equipos de Inteligencia Artificial
    `/project QuantumCoders` - Ver proyecto del equipo QuantumCoders
    `/join DataHackers` - Unirse al equipo DataHackers
    """
  end

  defp format_team(team) do
    "**#{team.name}** - #{team.category} (#{team.participant_count} miembros)"
  end

  defp format_project_response(project) do
    """
    **Proyecto: #{project.name}**
    **Descripción:** #{project.description}
    **Categoría:** #{project.category}
    **Actualizaciones:** #{length(project.updates)}
    **Feedback recibido:** #{length(project.feedback)}
    """
  end

  defp wrap_response(content, title) do
    "#{title}\n\n#{content}"
  end

  defp get_user_name(user_id) do
    "Usuario#{String.slice(user_id, 0, 5)}"
  end
end
