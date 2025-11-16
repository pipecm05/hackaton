# interactive.exs
defmodule HackathonInteractive do
  def start do
    IO.puts("""
    \e[36m
    ╔══════════════════════════════════════════════════════════════╗
    ║                   HACKATHON CODE4FUTURE                     ║
    ║               SISTEMA INTERACTIVO AUTOMÁTICO                ║
    ╚══════════════════════════════════════════════════════════════╝
    \e[0m
    """)

    # Cargar el sistema
    load_system()

    # Mostrar menú principal
    main_menu()
  end

  defp load_system do
    IO.puts("📦 Cargando sistema Hackathon...")

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

    Enum.each(modules, fn module ->
      if File.exists?(module) do
        Code.compile_file(module)
        IO.puts("#{Path.basename(module)}")
      else
        IO.puts(" No encontrado: #{module}")
      end
    end)

    # Iniciar sistema
    Hackathon.start()
  end

  defp main_menu do
    IO.puts("""
    \n\e[32m
    MENÚ PRINCIPAL - ¿QUÉ QUIERES HACER?
    ========================================

    1. GESTIÓN DE PARTICIPANTES
    2. GESTIÓN DE EQUIPOS
    3. GESTIÓN DE PROYECTOS
    4. SISTEMA DE CHAT
    5. SISTEMA DE MENTORÍA
    6. VER REPORTES DEL SISTEMA
    7. MODO AUTOMÁTICO (DEMO)
    8. SALIR

    \e[0m
    """)

    IO.write("Selecciona una opción (1-8): ")

    case IO.read(:line) |> String.trim() do
      "1" -> participantes_menu()
      "2" -> equipos_menu()
      "3" -> proyectos_menu()
      "4" -> chat_menu()
      "5" -> mentoría_menu()
      "6" -> reportes_menu()
      "7" -> modo_automatico()
      "8" -> salir()
      _ ->
        IO.puts("\e[31m Opción inválida. Intenta de nuevo.\e[0m")
        main_menu()
    end
  end

  # 1. MENÚ DE PARTICIPANTES
  defp participantes_menu do
    IO.puts("""
    \n\e[34m
    👥 GESTIÓN DE PARTICIPANTES
    ===========================

    1. Registrar nuevo participante
    2. Ver participantes existentes
    3. Volver al menú principal
    \e[0m
    """)

    IO.write("Selecciona una opción (1-3): ")

    case IO.read(:line) |> String.trim() do
      "1" -> registrar_participante()
      "2" -> ver_participantes()
      "3" -> main_menu()
      _ ->
        IO.puts("\e[31m Opción inválida\e[0m")
        participantes_menu()
    end
  end

  defp registrar_participante do
    IO.puts("\n REGISTRAR NUEVO PARTICIPANTE")
    IO.write("   ID del participante: ")
    id = IO.read(:line) |> String.trim()

    IO.write("   Nombre completo: ")
    nombre = IO.read(:line) |> String.trim()

    IO.write("   Email: ")
    email = IO.read(:line) |> String.trim()

    case Hackathon.TeamManagement.register_participant(id, nombre, email) do
      {:ok, participante} ->
        IO.puts("\e[32m Participante registrado: #{participante.name}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    participantes_menu()
  end

  defp ver_participantes do
    IO.puts("\n PARTICIPANTES REGISTRADOS:")
    # En un sistema real aquí obtendrías la lista de participantes
    IO.puts(" Función en desarrollo...")
    participantes_menu()
  end

  # 2. MENÚ DE EQUIPOS
  defp equipos_menu do
    IO.puts("""
    \n\e[34m
    GESTIÓN DE EQUIPOS
    =====================

    1. Crear nuevo equipo
    2. Unir participante a equipo
    3. Listar todos los equipos
    4. Buscar equipo por categoría
    5. Volver al menú principal
    \e[0m
    """)

    IO.write(" Selecciona una opción (1-5): ")

    case IO.read(:line) |> String.trim() do
      "1" -> crear_equipo()
      "2" -> unir_a_equipo()
      "3" -> listar_equipos()
      "4" -> buscar_equipos_categoria()
      "5" -> main_menu()
      _ ->
        IO.puts("\e[31m Opción inválida\e[0m")
        equipos_menu()
    end
  end

  defp crear_equipo do
    IO.puts("\n🆕 CREAR NUEVO EQUIPO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   Nombre del equipo: ")
    nombre = IO.read(:line) |> String.trim()

    IO.write("   ID del creador: ")
    creador_id = IO.read(:line) |> String.trim()

    IO.write("   Categoría (IA, Web, Mobile, Data, Blockchain): ")
    categoria = IO.read(:line) |> String.trim()

    case Hackathon.TeamManagement.create_team(equipo_id, nombre, creador_id, categoria) do
      {:ok, equipo} ->
        IO.puts("\e[32m Equipo creado: #{equipo.name} - #{equipo.category}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    equipos_menu()
  end

  defp unir_a_equipo do
    IO.puts("\n UNIR PARTICIPANTE A EQUIPO")
    IO.write("   ID del participante: ")
    participante_id = IO.read(:line) |> String.trim()

    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    case Hackathon.TeamManagement.join_team(participante_id, equipo_id) do
      {:ok, equipo} ->
        IO.puts("\e[32m Participante unido al equipo: #{equipo.name}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    equipos_menu()
  end

  defp listar_equipos do
    IO.puts("\n LISTA DE EQUIPOS:")

    case Hackathon.TeamManagement.list_teams() do
      {:ok, equipos} ->
        if Enum.empty?(equipos) do
          IO.puts("   No hay equipos registrados")
        else
          Enum.each(equipos, fn equipo ->
            IO.puts("  #{equipo.name} - #{equipo.category} (#{equipo.participant_count} miembros)")
          end)
          IO.puts("    Total: #{length(equipos)} equipos")
        end
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    equipos_menu()
  end

  defp buscar_equipos_categoria do
    IO.puts("\n BUSCAR EQUIPOS POR CATEGORÍA")
    IO.write("   Categoría (IA, Web, Mobile, Data, Blockchain): ")
    categoria = IO.read(:line) |> String.trim()

    case Hackathon.TeamManagement.list_teams_by_category(categoria) do
      {:ok, equipos} ->
        if Enum.empty?(equipos) do
          IO.puts("   No hay equipos en la categoría: #{categoria}")
        else
          IO.puts("   Equipos en #{categoria}:")
          Enum.each(equipos, fn equipo ->
            IO.puts("    #{equipo.name} (#{equipo.participant_count} miembros)")
          end)
        end
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    equipos_menu()
  end

  # 3. MENÚ DE PROYECTOS
  defp proyectos_menu do
    IO.puts("""
    \n\e[34m
     GESTIÓN DE PROYECTOS
    =======================

    1. Registrar nuevo proyecto
    2. Actualizar avance de proyecto
    3. Ver proyecto de equipo
    4. Listar proyectos por categoría
    5. Volver al menú principal
    \e[0m
    """)

    IO.write(" Selecciona una opción (1-5): ")

    case IO.read(:line) |> String.trim() do
      "1" -> registrar_proyecto()
      "2" -> actualizar_proyecto()
      "3" -> ver_proyecto_equipo()
      "4" -> listar_proyectos_categoria()
      "5" -> main_menu()
      _ ->
        IO.puts("\e[31m Opción inválida\e[0m")
        proyectos_menu()
    end
  end

  defp registrar_proyecto do
    IO.puts("\n REGISTRAR NUEVO PROYECTO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   Nombre del proyecto: ")
    nombre = IO.read(:line) |> String.trim()

    IO.write("   Descripción: ")
    descripcion = IO.read(:line) |> String.trim()

    IO.write("   Categoría: ")
    categoria = IO.read(:line) |> String.trim()

    case Hackathon.ProjectRegistry.register_project(equipo_id, nombre, descripcion, categoria) do
      {:ok, proyecto} ->
        IO.puts("\e[32m Proyecto registrado: #{proyecto.name}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    proyectos_menu()
  end

  defp actualizar_proyecto do
    IO.puts("\n ACTUALIZAR AVANCE DE PROYECTO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   Mensaje de avance: ")
    mensaje = IO.read(:line) |> String.trim()

    :ok = Hackathon.ProjectRegistry.update_project(equipo_id, mensaje)
    IO.puts("\e[32m Avance registrado para el equipo: #{equipo_id}\e[0m")

    proyectos_menu()
  end

  defp ver_proyecto_equipo do
    IO.puts("\n VER PROYECTO DE EQUIPO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    case Hackathon.ProjectRegistry.get_team_project(equipo_id) do
      {:ok, proyecto} ->
        IO.puts("""
        \e[33m
         PROYECTO: #{proyecto.name}
         Descripción: #{proyecto.description}
         Categoría: #{proyecto.category}
         Actualizaciones: #{length(proyecto.updates)}
        \e[0m
        """)

        # Mostrar últimas actualizaciones
        if proyecto.updates != [] do
          IO.puts("   Últimas actualizaciones:")
          Enum.take(proyecto.updates, 3) |> Enum.each(fn update ->
            IO.puts("    #{update.message}")
          end)
        end

      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    proyectos_menu()
  end

  # FUNCIÓN FALTANTE - AÑADIR ESTA
  defp listar_proyectos_categoria do
    IO.puts("\n LISTAR PROYECTOS POR CATEGORÍA")
    IO.write("   Categoría (IA, Web, Mobile, Data, Blockchain): ")
    categoria = IO.read(:line) |> String.trim()

    case Hackathon.ProjectRegistry.get_projects_by_category(categoria) do
      {:ok, proyectos} ->
        if Enum.empty?(proyectos) do
          IO.puts("   No hay proyectos en la categoría: #{categoria}")
        else
          IO.puts("   Proyectos en #{categoria}:")
          Enum.each(proyectos, fn proyecto ->
            IO.puts("    #{proyecto.name} - Equipo: #{proyecto.team_id}")
            IO.puts("       #{proyecto.description}")
            IO.puts("")
          end)
        end
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    proyectos_menu()
  end

  # 4. MENÚ DE CHAT
  defp chat_menu do
    IO.puts("""
    \n\e[34m
     SISTEMA DE CHAT
    ==================

    1. Crear sala de chat
    2. Unirse a sala
    3. Enviar mensaje
    4. Ver historial de mensajes
    5. Volver al menú principal
    \e[0m
    """)

    IO.write(" Selecciona una opción (1-5): ")

    case IO.read(:line) |> String.trim() do
      "1" -> crear_sala_chat()
      "2" -> unirse_sala_chat()
      "3" -> enviar_mensaje_chat()
      "4" -> ver_historial_chat()
      "5" -> main_menu()
      _ ->
        IO.puts("\e[31m Opción inválida\e[0m")
        chat_menu()
    end
  end

  defp crear_sala_chat do
    IO.puts("\n CREAR SALA DE CHAT")
    IO.write("   Nombre de la sala: ")
    sala = IO.read(:line) |> String.trim()

    IO.write("   Tema de la sala: ")
    tema = IO.read(:line) |> String.trim()

    case Hackathon.ChatSystem.create_room(sala, tema) do
      {:ok, _} ->
        IO.puts("\e[32m Sala creada: #{sala} - #{tema}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    chat_menu()
  end

  defp unirse_sala_chat do
    IO.puts("\n UNIRSE A SALA DE CHAT")
    IO.write("   Nombre de la sala: ")
    sala = IO.read(:line) |> String.trim()

    IO.write("   Tu ID de usuario: ")
    usuario_id = IO.read(:line) |> String.trim()

    IO.write("   Tu nombre: ")
    nombre = IO.read(:line) |> String.trim()

    case Hackathon.ChatSystem.join_room(sala, usuario_id, nombre) do
      {:ok, _} ->
        IO.puts("\e[32m Te uniste a la sala: #{sala}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    chat_menu()
  end

  defp enviar_mensaje_chat do
    IO.puts("\n ENVIAR MENSAJE DE CHAT")
    IO.write("   Sala: ")
    sala = IO.read(:line) |> String.trim()

    IO.write("   Tu ID de usuario: ")
    usuario_id = IO.read(:line) |> String.trim()

    IO.write("   Mensaje: ")
    mensaje = IO.read(:line) |> String.trim()

    :ok = Hackathon.ChatSystem.send_message(sala, usuario_id, mensaje)
    IO.puts("\e[32m Mensaje enviado a #{sala}\e[0m")

    chat_menu()
  end

  defp ver_historial_chat do
    IO.puts("\n VER HISTORIAL DE CHAT")
    IO.write("   Sala: ")
    sala = IO.read(:line) |> String.trim()

    IO.write("   Límite de mensajes: ")
    limite = IO.read(:line) |> String.trim() |> String.to_integer()

    case Hackathon.ChatSystem.get_message_history(sala, limite) do
      {:ok, mensajes} ->
        if Enum.empty?(mensajes) do
          IO.puts("   No hay mensajes en esta sala")
        else
          IO.puts("   Mensajes en #{sala}:")
          Enum.each(mensajes, fn mensaje ->
            IO.puts("   #{mensaje.participant_name}: #{mensaje.content}")
          end)
        end
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    chat_menu()
  end

  # 5. MENÚ DE MENTORÍA
  defp mentoría_menu do
    IO.puts("""
    \n\e[34m
    SISTEMA DE MENTORÍA
    ===================

    1. Registrar mentor
    2. Asignar mentor a equipo
    3. Enviar consulta
    4. Enviar feedback
    5. Ver feedback de equipo
    6. Volver al menú principal
    \e[0m
    """)

    IO.write(" Selecciona una opción (1-6): ")

    case IO.read(:line) |> String.trim() do
      "1" -> registrar_mentor()
      "2" -> asignar_mentor()
      "3" -> enviar_consulta()
      "4" -> enviar_feedback()
      "5" -> ver_feedback_equipo()
      "6" -> main_menu()
      _ ->
        IO.puts("\e[31m Opción inválida\e[0m")
        mentoría_menu()
    end
  end

  defp registrar_mentor do
    IO.puts("\n REGISTRAR MENTOR")
    IO.write("   ID del mentor: ")
    mentor_id = IO.read(:line) |> String.trim()

    IO.write("   Nombre del mentor: ")
    nombre = IO.read(:line) |> String.trim()

    IO.write("   Especialidades (separadas por coma): ")
    especialidades = IO.read(:line) |> String.trim() |> String.split(",") |> Enum.map(&String.trim/1)

    case Hackathon.MentorshipSystem.register_mentor(mentor_id, nombre, especialidades) do
      {:ok, mentor} ->
        IO.puts("\e[32m Mentor registrado: #{mentor.name}\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    mentoría_menu()
  end

  defp asignar_mentor do
    IO.puts("\n ASIGNAR MENTOR A EQUIPO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   ID del mentor: ")
    mentor_id = IO.read(:line) |> String.trim()

    case Hackathon.MentorshipSystem.assign_mentor_to_team(equipo_id, mentor_id) do
      {:ok, _} ->
        IO.puts("\e[32m Mentor asignado al equipo\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    mentoría_menu()
  end

  defp enviar_consulta do
    IO.puts("\n ENVIAR CONSULTA")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   Consulta: ")
    consulta = IO.read(:line) |> String.trim()

    :ok = Hackathon.MentorshipSystem.send_inquiry(equipo_id, consulta)
    IO.puts("\e[32m Consulta enviada\e[0m")

    mentoría_menu()
  end

  defp enviar_feedback do
    IO.puts("\n ENVIAR FEEDBACK")
    IO.write("   ID del mentor: ")
    mentor_id = IO.read(:line) |> String.trim()

    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    IO.write("   Feedback: ")
    feedback = IO.read(:line) |> String.trim()

    case Hackathon.MentorshipSystem.send_feedback(mentor_id, equipo_id, feedback) do
      {:ok, _} ->
        IO.puts("\e[32m Feedback enviado\e[0m")
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    mentoría_menu()
  end

  defp ver_feedback_equipo do
    IO.puts("\n VER FEEDBACK DE EQUIPO")
    IO.write("   ID del equipo: ")
    equipo_id = IO.read(:line) |> String.trim()

    case Hackathon.MentorshipSystem.get_team_feedback(equipo_id) do
      {:ok, feedbacks} ->
        if Enum.empty?(feedbacks) do
          IO.puts("   No hay feedback para este equipo")
        else
          IO.puts("   Feedback para el equipo #{equipo_id}:")
          Enum.each(feedbacks, fn fb ->
            IO.puts("    #{fb.feedback}")
            IO.puts("     Mentor: #{fb.mentor_id}")
            IO.puts("")
          end)
        end
      {:error, razon} ->
        IO.puts("\e[31m Error: #{razon}\e[0m")
    end

    mentoría_menu()
  end

  # 6. REPORTES DEL SISTEMA
  defp reportes_menu do
    IO.puts("""
    \n\e[35m
     REPORTES DEL SISTEMA
    =======================
    \e[0m
    """)

    # Equipos
    case Hackathon.TeamManagement.list_teams() do
      {:ok, equipos} ->
        IO.puts(" EQUIPOS: #{length(equipos)}")
        Enum.each(equipos, fn equipo ->
          IO.puts("    #{equipo.name} - #{equipo.category} (#{equipo.participant_count} miembros)")
        end)
      _ -> IO.puts(" EQUIPOS: Error al cargar")
    end

    # Proyectos por categoría
    categorias = ["Inteligencia Artificial", "Desarrollo Web", "Data Science", "Mobile Development", "Blockchain"]
    IO.puts("\n PROYECTOS POR CATEGORÍA:")
    Enum.each(categorias, fn categoria ->
      case Hackathon.ProjectRegistry.get_projects_by_category(categoria) do
        {:ok, proyectos} when proyectos != [] ->
          IO.puts("    #{categoria}: #{length(proyectos)} proyectos")
        _ -> :ok
      end
    end)

    IO.write("\n Presiona Enter para volver al menú principal...")
    IO.read(:line)
    main_menu()
  end

  # 7. MODO AUTOMÁTICO - DEMO COMPLETA
  defp modo_automatico do
    IO.puts("""
    \n\e[33m
     MODO AUTOMÁTICO - DEMOSTRACIÓN AUTOMATICA COMPLETA
    ==========================================
    \e[0m
    """)

    demo_step("1.Creando participantes de ejemplo...", 500)
    Hackathon.TeamManagement.register_participant("auto1", "Juan Automático", "juan@demo.com")
    Hackathon.TeamManagement.register_participant("auto2", "María Demo", "maria@demo.com")

    demo_step("2. Creando equipos automáticos...", 500)
    Hackathon.TeamManagement.create_team("auto_team", "Equipo Automático", "auto1", "Demo")
    Hackathon.TeamManagement.join_team("auto2", "auto_team")

    demo_step("3.Registrando proyecto demo...", 500)
    Hackathon.ProjectRegistry.register_project("auto_team", "Proyecto Demo",
      "Proyecto de demostración automática", "Demo")

    demo_step("4.Actualizando progreso...", 500)
    Hackathon.ProjectRegistry.update_project("auto_team", "Primera actualización automática")
    Hackathon.ProjectRegistry.update_project("auto_team", "Segundo avance del proyecto")

    demo_step("5. Probando chat...", 500)
    Hackathon.ChatSystem.create_room("demo_auto", "Sala de demostración automática")
    Hackathon.ChatSystem.join_room("demo_auto", "auto1", "Juan")
    Hackathon.ChatSystem.send_message("demo_auto", "auto1", "¡Hola desde el modo automático!")

    demo_step("6. Configurando mentoría...", 500)
    Hackathon.MentorshipSystem.register_mentor("auto_mentor", "Mentor Automático", ["Demo", "Testing"])
    Hackathon.MentorshipSystem.send_feedback("auto_mentor", "auto_team", "¡Excelente trabajo equipo automático!")

    IO.puts("""
    \n\e[32m
    DEMOSTRACIÓN AUTOMÁTICA COMPLETADA
    =====================================

    Se crearon:
    • 2 participantes nuevos
    • 1 equipo automático
    • 1 proyecto demo
    • 2 actualizaciones de progreso
    • 1 sala de chat con mensaje
    • 1 mentor con feedback

    ¡El sistema funciona perfectamente!
    \e[0m
    """)

    IO.write("\nPresiona Enter para volver al menú principal...")
    IO.read(:line)
    main_menu()
  end

  defp demo_step(mensaje, delay) do
    IO.puts("   #{mensaje}")
    :timer.sleep(delay)
  end

  defp salir do
    IO.puts("""
    \n\e[36m
    Hackaton finalizado
    =====================

    ¡Hasta la próxima!
    \e[0m
    """)
    System.halt(0)
  end
end

# Iniciar el sistema interactivo
HackathonInteractive.start()
