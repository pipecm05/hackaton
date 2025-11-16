# main.exs
defmodule HackathonCLI do
  @moduledoc """
  Interfaz de línea de comandos para el sistema Hackathon Code4Future
  """

  def main(args \\ []) do
    {options, commands, _} = OptionParser.parse(args,
      strict: [help: :boolean, demo: :boolean, interactive: :boolean],
      aliases: [h: :help, d: :demo, i: :interactive]
    )

    IO.puts(header())

    case {options, commands} do
      {[help: true], _} ->
        show_help()

      {[demo: true], _} ->
        run_demo_mode()

      {[interactive: true], _} ->
        start_interactive_mode()

      {_, []} ->
        start_normal_mode()

      {_, [command | _]} ->
        execute_single_command(command, Enum.drop(commands, 1))

      _ ->
        show_help()
    end
  end

  defp header do
    """
    \e[36m
    ╔══════════════════════════════════════════════════════════════╗
    ║                   HACKATHON CODE4FUTURE                     ║
    ║               Sistema Colaborativo en Elixir                ║
    ║                                                              ║
    ║    🚀 Gestión de Equipos • 💬 Chat • 📊 Proyectos • 👨‍🏫 Mentoría   ║
    ╚══════════════════════════════════════════════════════════════╝
    \e[0m
    """
  end

  defp show_help do
    """
    \e[32m
    📖 USO: elixir main.exs [OPCIONES] [COMANDO]

    OPCIONES:
      -h, --help          Muestra esta ayuda
      -d, --demo          Ejecuta modo demostración automática
      -i, --interactive   Inicia modo interactivo

    COMANDOS RÁPIDOS:
      teams               Listar equipos
      projects            Listar proyectos
      chat <sala>         Unirse a sala de chat
      join <equipo>       Unirse a equipo
      status              Estado del sistema

    EJEMPLOS:
      elixir main.exs --demo
      elixir main.exs --interactive
      elixir main.exs teams
      elixir main.exs chat general
      elixir main.exs join "AI Innovators"

    \e[0m
    """ |> IO.puts()
  end

  defp run_demo_mode do
    IO.puts("\n\e[33m🎮 MODO DEMOSTRACIÓN INICIADO\e[0m")
    IO.puts("⏳ Cargando sistema...")

    load_system()
    DemoRunner.run_complete_demo()
  end

  defp start_interactive_mode do
    IO.puts("\n\e[36m💻 MODO INTERACTIVO\e[0m")
    IO.puts("Cargando sistema Hackathon...")

    load_system()

    IO.puts("""
    \e[32m
    ✅ Sistema cargado correctamente
    💡 Escribe 'help' para ver comandos disponibles
    💡 Escribe 'exit' para salir
    \e[0m
    """)

    interactive_loop()
  end

  defp start_normal_mode do
    IO.puts("\n\e[34m🚀 INICIANDO SISTEMA HACKATHON\e[0m")

    load_system()

    IO.puts("""
    \e[32m
    ✅ Sistema iniciado correctamente
    📊 Estado del sistema:
    \e[0m
    """)

    show_system_status()

    IO.puts("""
    \e[33m
    💡 Usa 'elixir main.exs --interactive' para modo interactivo
    💡 Usa 'elixir main.exs --demo' para ver una demostración
    💡 Usa 'elixir main.exs --help' para ayuda completa
    \e[0m
    """)
  end

  defp execute_single_command(command, args) do
    IO.puts("\n\e[35m🎯 EJECUTANDO COMANDO: #{command}\e[0m")

    load_system()

    case command do
      "teams" ->
        list_teams()

      "projects" ->
        list_projects()

      "chat" when args != [] ->
        [room | _] = args
        join_chat_room(room)

      "join" when args != [] ->
        [team | _] = args
        join_team(team)

      "status" ->
        show_system_status()

      _ ->
        IO.puts("\e[31m❌ Comando desconocido: #{command}\e[0m")
        IO.puts("💡 Usa 'elixir main.exs --help' para ver comandos disponibles")
    end
  end

  defp load_system do
    modules = [
      "lib/hackathon.ex",
      "lib/hackathon/application.ex",
      "lib/hackathon/supervisor.ex",
      "lib/hackathon/auth.ex",
      "lib/hackathon/distributed_registry.ex",
      "lib/hackathon/team_management.ex",
      "lib/hackathon/project_registry.ex",
      "lib/hackathon/chat_system.ex",
      "lib/hackathon/mentorship_system.ex",
      "lib/hackathon/command_handler.ex"
    ]

    IO.puts("📦 Cargando módulos...")

    Enum.each(modules, fn module ->
      if File.exists?(module) do
        Code.compile_file(module)
        IO.puts("   ✅ #{Path.basename(module)}")
      else
        IO.puts("   ❌ No encontrado: #{module}")
      end
    end)

    case Hackathon.start() do
      :ok ->
        IO.puts("✅ Aplicación iniciada")
        :ok
      error ->
        IO.puts("❌ Error iniciando aplicación: #{inspect(error)}")
        error
    end
  end

  defp interactive_loop do
    IO.write("\n\e[36mhackathon> \e[0m")

    input = IO.read(:line) |> String.trim()

    case input do
      "exit" ->
        IO.puts("👋 ¡Hasta pronto!")
        System.halt(0)

      "quit" ->
        IO.puts("👋 Cerrando sistema...")
        System.halt(0)

      "help" ->
        show_interactive_help()
        interactive_loop()

      "teams" ->
        list_teams()
        interactive_loop()

      "projects" ->
        list_projects()
        interactive_loop()

      "status" ->
        show_system_status()
        interactive_loop()

      "clear" ->
        IO.write("\e[2J\e[H")
        interactive_loop()

      "" ->
        interactive_loop()

      command ->
        cond do
          String.starts_with?(command, "/") ->
            execute_system_command(command)
            interactive_loop()

          String.starts_with?(command, "chat ") ->
            room = String.replace(command, "chat ", "") |> String.trim()
            join_chat_room(room)
            interactive_loop()

          String.starts_with?(command, "join ") ->
            team = String.replace(command, "join ", "") |> String.trim()
            join_team(team)
            interactive_loop()

          true ->
            IO.puts("\e[31m❌ Comando desconocido: #{command}\e[0m")
            IO.puts("💡 Escribe 'help' para ver comandos disponibles")
            interactive_loop()
        end
    end
  end

  defp show_interactive_help do
    IO.puts("""
    \e[32m
    🎯 COMANDOS INTERACTIVOS:

    📊 INFORMACIÓN:
      teams       - Listar equipos activos
      projects    - Listar proyectos
      status      - Estado del sistema

    👥 GESTIÓN:
      join <equipo>    - Unirse a un equipo
      /teams           - Listar equipos (formato comando)
      /project <equipo> - Ver proyecto de equipo

    💬 CHAT:
      chat <sala>      - Unirse a sala de chat
      /chat <sala>     - Unirse a sala (formato comando)

    🛠️ SISTEMA:
      clear       - Limpiar pantalla
      help        - Mostrar esta ayuda
      exit        - Salir del sistema

    📝 EJEMPLOS:
      join "AI Innovators"
      chat general
      /teams
      /project team_ai
    \e[0m
    """)
  end

  defp list_teams do
    case Hackathon.TeamManagement.list_teams() do
      {:ok, teams} ->
        IO.puts("\n\e[34m👥 EQUIPOS ACTIVOS:\e[0m")
        Enum.each(teams, fn team ->
          IO.puts("   🏆 #{team.name} - #{team.category} (#{team.participant_count} miembros)")
        end)
        IO.puts("   📊 Total: #{length(teams)} equipos")

      {:error, reason} ->
        IO.puts("\e[31m❌ Error listando equipos: #{reason}\e[0m")
    end
  end

  defp list_projects do
    categories = ["Inteligencia Artificial", "Desarrollo Web"]

    IO.puts("\n\e[34m🚀 PROYECTOS REGISTRADOS:\e[0m")

    Enum.each(categories, fn category ->
      case Hackathon.ProjectRegistry.get_projects_by_category(category) do
        {:ok, projects} when projects != [] ->
          IO.puts("   📁 #{category}:")
          Enum.each(projects, fn project ->
            IO.puts("      🎯 #{project.name} - #{project.team_id}")
          end)

        _ ->
          :ok
      end
    end)
  end

  defp join_chat_room(room) do
    user_id = "user_#{:rand.uniform(1000)}"
    user_name = "Usuario#{:rand.uniform(1000)}"

    case Hackathon.ChatSystem.join_room(room, user_id, user_name) do
      {:ok, _room} ->
        IO.puts("✅ Conectado a sala: #{room}")

      {:error, reason} ->
        IO.puts("❌ Error uniéndose a sala: #{reason}")
    end
  end

  defp join_team(team) do
    user_id = "user_#{:rand.uniform(1000)}"

    Hackathon.TeamManagement.register_participant(user_id, "Usuario#{:rand.uniform(1000)}", "test@example.com")

    case Hackathon.TeamManagement.join_team(user_id, team) do
      {:ok, team_info} ->
        IO.puts("✅ Te uniste al equipo: #{team_info.name}")

      {:error, reason} ->
        IO.puts("❌ Error uniéndose al equipo: #{reason}")
    end
  end

  defp show_system_status do
    IO.puts("\n\e[35m📊 ESTADO DEL SISTEMA:\e[0m")

    services = [
      {"Gestión de Equipos", Hackathon.TeamManagement},
      {"Registro de Proyectos", Hackathon.ProjectRegistry},
      {"Sistema de Chat", Hackathon.ChatSystem},
      {"Sistema de Mentoría", Hackathon.MentorshipSystem},
      {"Manejador de Comandos", Hackathon.CommandHandler}
    ]

    Enum.each(services, fn {name, module} ->
      case Process.whereis(module) do
        pid when is_pid(pid) ->
          IO.puts("   ✅ #{name} - \e[32mACTIVO\e[0m")
        _ ->
          IO.puts("   ❌ #{name} - \e[31mINACTIVO\e[0m")
      end
    end)
  end

  defp execute_system_command(command) do
    user_id = "cli_user_#{:rand.uniform(1000)}"

    case Hackathon.execute_command(command, user_id) do
      response when is_binary(response) ->
        IO.puts("\n#{response}")

      _ ->
        IO.puts("\e[31m❌ Error ejecutando comando\e[0m")
    end
  end
end

defmodule DemoRunner do
  def run_complete_demo do
    IO.puts("\n\e[36m🎬 INICIANDO DEMOSTRACIÓN COMPLETA\e[0m")

    sleep = fn ms -> :timer.sleep(ms) end

    demo_step("1. 📋 Mostrando ayuda del sistema", 500)
    IO.puts(Hackathon.execute_command("/help"))
    sleep.(1000)

    demo_step("2. 👥 Listando equipos registrados", 500)
    IO.puts(Hackathon.execute_command("/teams"))
    sleep.(1000)

    demo_step("3. 🚀 Viendo proyecto de ejemplo", 500)
    IO.puts(Hackathon.execute_command("/project team_ai"))
    sleep.(1000)

    IO.puts("\n\e[32m🎉 DEMOSTRACIÓN COMPLETADA!\e[0m")
  end

  defp demo_step(message, delay) do
    IO.puts("\n\e[35m#{message}\e[0m")
    :timer.sleep(delay)
  end
end

if System.get_env("HACKATHON_TEST") do
  :ok
else
  HackathonCLI.main(System.argv())
end
