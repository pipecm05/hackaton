defmodule Hackathon do
  @moduledoc """
  Módulo principal de la aplicación Hackathon Code4Future
  """

  def start do
    IO.puts("🚀 Iniciando Hackathon Code4Future...")

    # Solo iniciar la aplicación (sin supervisor duplicado)
    case Hackathon.Application.start(:normal, []) do
      {:ok, _pid} ->
        create_sample_data()
        IO.puts("✅ Sistema Hackathon iniciado correctamente!")
        :ok
      error ->
        IO.puts("❌ Error iniciando sistema: #{inspect(error)}")
        error
    end
  end

  defp create_sample_data do
    # Registrar participantes de ejemplo
    Hackathon.TeamManagement.register_participant("user1", "Ana García", "ana@example.com")
    Hackathon.TeamManagement.register_participant("user2", "Carlos López", "carlos@example.com")
    Hackathon.TeamManagement.register_participant("user3", "María Rodríguez", "maria@example.com")

    # Crear equipos de ejemplo
    Hackathon.TeamManagement.create_team("team_ai", "AI Innovators", "user1", "Inteligencia Artificial")
    Hackathon.TeamManagement.create_team("team_web", "Web Masters", "user2", "Desarrollo Web")

    # Registrar proyectos
    Hackathon.ProjectRegistry.register_project("team_ai", "Sistema de Recomendación",
      "Sistema de IA para recomendaciones personalizadas", "Inteligencia Artificial")

    Hackathon.ProjectRegistry.register_project("team_web", "Plataforma Educativa",
      "Plataforma web para educación en línea", "Desarrollo Web")

    # Registrar mentores
    Hackathon.MentorshipSystem.register_mentor("mentor1", "Dr. Smith", ["IA", "Machine Learning"])
    Hackathon.MentorshipSystem.register_mentor("mentor2", "Ing. Johnson", ["Web Development", "Cloud"])

    IO.puts("📊 Datos de ejemplo creados exitosamente!")
  end

  @doc """
  Ejecutar comando del sistema
  """
  def execute_command(command, user_id \\ "default_user") do
    Hackathon.CommandHandler.process_command(command, user_id)
  end
end
