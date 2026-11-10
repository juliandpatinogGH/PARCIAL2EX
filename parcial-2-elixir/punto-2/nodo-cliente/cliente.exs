# Punto 2: nodo cliente.
# Ejecutar desde la carpeta punto-2/nodo-cliente (con el servidor ya iniciado):
#   elixir cliente.exs
# El script inicia solo el nodo "cliente" con la cookie "sismos" (módulo Nodo).
#
# Por defecto se conecta a servidor@<nombre de este equipo>.
# Si el servidor está en otro nodo, se puede indicar como argumento:
#   elixir cliente.exs servidor@OTRO_EQUIPO

Code.require_file("../nodo.exs", __DIR__)

defmodule ClienteSismos do
  @ciudad_con_movimientos "C01"
  @ciudad_sin_movimientos "C03"
  @ciudad_inexistente "C99"

  def iniciar(nodo_servidor) do
    case Nodo.iniciar(:cliente) do
      :ok -> conectar(nodo_servidor)
      :error -> IO.puts("Error: no se pudo iniciar el nodo cliente")
    end
  end

  defp conectar(nodo_servidor) do
    Process.register(self(), :servicio_respuesta)
    IO.puts("Conectando con #{nodo_servidor}...")

    case Node.connect(nodo_servidor) do
      true ->
        IO.puts("Conexión exitosa.\n")
        enviar_solicitudes(nodo_servidor)
        recibir_respuestas()

      _ ->
        IO.puts("Error: no se pudo conectar con el nodo #{nodo_servidor}")
    end
  end

  defp enviar_solicitudes(nodo_servidor) do
    servicio = {:servicio_sismos, nodo_servidor}
    destino_respuesta = {:servicio_respuesta, node()}

    send(servicio, {destino_respuesta, {:reporte_ciudad, @ciudad_con_movimientos}})
    send(servicio, {destino_respuesta, {:reporte_ciudad, @ciudad_sin_movimientos}})
    send(servicio, {destino_respuesta, {:reporte_ciudad, @ciudad_inexistente}})
    send(servicio, {destino_respuesta, :reporte_general})
    send(servicio, {destino_respuesta, :fin})
  end

  # Recibe y muestra respuestas de forma recursiva hasta que llegue :fin.
  defp recibir_respuestas do
    receive do
      {:respuesta, texto} ->
        IO.puts(texto)
        recibir_respuestas()

      :fin ->
        IO.puts("El servidor confirmó :fin. Cliente finalizado.")
    end
  end
end

defmodule NodoServidor do
  # Usa el argumento si se pasó uno; si no, arma "servidor@<equipo>".
  def obtener_nombre(argumentos) do
    case argumentos do
      [nombre] ->
        String.to_atom(nombre)

      [] ->
        {:ok, equipo} = :inet.gethostname()
        String.to_atom("servidor@#{equipo}")
    end
  end
end

ClienteSismos.iniciar(NodoServidor.obtener_nombre(System.argv()))
