defmodule Nodo do
  @moduledoc """
  Convierte el programa en un nodo de Elixir para que el servidor y el cliente
  puedan comunicarse. Lo usan servidor.exs y cliente.exs.
  """

  @cookie :sismos

  # Inicia el nodo con el nombre indicado y la cookie :sismos.
  # Si el programa ya se inició con --sname, solo se asigna la cookie.
  # Devuelve :ok si el programa quedó como nodo, o :error si no se pudo.
  def iniciar(nombre) do
    if not Node.alive?() do
      iniciar_epmd()
      esperar_epmd(20)
      Node.start(nombre, :shortnames)
    end

    if Node.alive?() do
      Node.set_cookie(@cookie)
      :ok
    else
      :error
    end
  end

  # epmd es el programa de Erlang que permite que los nodos se encuentren.
  # Se ejecuta en un proceso aparte (spawn) porque System.cmd espera a que epmd
  # termine, y epmd se queda corriendo. Si epmd ya estaba activo, el nuevo se
  # cierra solo; stderr_to_stdout evita que su mensaje aparezca en consola.
  # (No se usa "epmd -daemon" porque en Windows se cierra si no lo lanza erl.)
  defp iniciar_epmd do
    spawn(fn -> System.cmd(ruta_epmd(), [], stderr_to_stdout: true) end)
  end

  # epmd tarda un momento en quedar listo después de iniciarse.
  # Se pregunta cada 200 ms (máximo "intentos" veces) hasta que responda.
  defp esperar_epmd(0), do: :error

  defp esperar_epmd(intentos) do
    case :erl_epmd.names() do
      {:ok, _nodos} ->
        :ok

      _ ->
        Process.sleep(200)
        esperar_epmd(intentos - 1)
    end
  end

  # epmd está en la carpeta erts-<versión>/bin de la instalación de Erlang.
  defp ruta_epmd do
    version = to_string(:erlang.system_info(:version))
    carpeta = Path.join([to_string(:code.root_dir()), "erts-" <> version, "bin"])

    case :os.type() do
      {:win32, _} -> Path.join(carpeta, "epmd.exe")
      _ -> Path.join(carpeta, "epmd")
    end
  end
end
