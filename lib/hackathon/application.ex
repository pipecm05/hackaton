defmodule Hackathon.Application do
  use Application

 def start(_type, _args) do
    IO.puts("Iniciando aplicación Hackathon...")

    children = [
      {Hackathon.DistributedRegistry, []},
      {Hackathon.TeamManagement, []},
      {Hackathon.ProjectRegistry, []},
      {Hackathon.ChatSystem, []},
      {Hackathon.MentorshipSystem, []}
    ]

    case Supervisor.start_link(children, strategy: :one_for_one, name: Hackathon.ApplicationSupervisor) do
      {:ok, pid} ->
        IO.puts("Aplicación iniciada correctamente")
        {:ok, pid}
      error ->
        IO.puts("Error iniciando aplicación: #{inspect(error)}")
        error
    end
  end
end
