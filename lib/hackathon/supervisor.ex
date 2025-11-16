defmodule Hackathon.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    IO.puts("Iniciando supervisor principal...")
    case Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__) do
      {:ok, pid} ->
        IO.puts("Supervisor iniciado correctamente")
        {:ok, pid}
      error ->
        IO.puts("Error iniciando supervisor: #{inspect(error)}")
        error
    end
  end

  def init(_init_arg) do
    IO.puts(" Configurando procesos supervisados...")
    children = [
      {Hackathon.Auth, []},
      {Hackathon.CommandHandler, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
