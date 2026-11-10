# Punto 2: nodo servidor.
# Ejecutar desde la carpeta punto-2/nodo-servidor:
#   elixir servidor.exs
# El script inicia solo el nodo "servidor" con la cookie "sismos" (módulo Nodo).

Code.require_file("../nodo.exs", __DIR__)

# Se reutilizan los structs, validaciones y cálculos del punto 1.
carpeta_punto_1 = Path.expand("../../punto-1", __DIR__)

Code.require_file("ciudad.exs", carpeta_punto_1)
Code.require_file("movimiento.exs", carpeta_punto_1)
Code.require_file("validador.exs", carpeta_punto_1)
Code.require_file("archivos.exs", carpeta_punto_1)
Code.require_file("coordinador.exs", carpeta_punto_1)
Code.require_file("estadisticas.exs", carpeta_punto_1)
Code.require_file("procesador.exs", carpeta_punto_1)
Code.require_file("reporte.exs", carpeta_punto_1)

defmodule ServidorSismos do
  @ruta_ciudades "resources/ciudades.txt"
  @ruta_movimientos "resources/movimientos.txt"

  def iniciar do
    case Nodo.iniciar(:servidor) do
      :ok ->
        Process.register(self(), :servicio_sismos)
        IO.puts("Servidor #{node()} listo. Proceso :servicio_sismos esperando solicitudes...")
        esperar_solicitudes()

      :error ->
        IO.puts("Error: no se pudo iniciar el nodo servidor (¿ya hay otro servidor abierto?)")
    end
  end

  # Atiende una solicitud a la vez. Como cada respuesta se envía antes de
  # volver a llamar a receive, las respuestas salen en el mismo orden en que
  # llegaron las solicitudes.
  def esperar_solicitudes do
    receive do
      {destino, :fin} ->
        IO.puts("Solicitud :fin recibida. Enviando confirmación.")
        send(destino, :fin)

      {destino, solicitud} ->
        IO.puts("Solicitud recibida: #{inspect(solicitud)}")
        send(destino, {:respuesta, atender(solicitud)})
    end

    esperar_solicitudes()
  end

  defp atender({:reporte_ciudad, id_ciudad}) do
    generar_respuesta(fn datos -> Reporte.generar_ciudad(datos, id_ciudad) end)
  end

  defp atender(:reporte_general) do
    generar_respuesta(fn datos -> Reporte.generar_general(datos) end)
  end

  defp atender(solicitud) do
    "Solicitud no reconocida: #{inspect(solicitud)}"
  end

  # Lee concurrentemente las versiones actuales de los archivos (Coordinador del
  # punto 1) y, si la lectura es exitosa, arma el reporte con la función recibida.
  defp generar_respuesta(funcion_reporte) do
    case Coordinador.leer_archivos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos_ciudades, datos_movimientos} ->
        datos = ProcesadorSismos.procesar(datos_ciudades, datos_movimientos)
        funcion_reporte.(datos)

      {:error, errores} ->
        Reporte.generar_errores(errores)
    end
  end
end

ServidorSismos.iniciar()
