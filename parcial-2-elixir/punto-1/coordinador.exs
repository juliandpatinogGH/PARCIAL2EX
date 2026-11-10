defmodule Coordinador do
  @moduledoc """
  Coordina la lectura concurrente de los dos archivos.

  El proceso que llama a leer_archivos/2 actúa como coordinador:
    1. Inicia (spawn) un trabajador para ciudades y otro para movimientos.
    2. Después de iniciar ambos, espera sus mensajes en cualquier orden.

  Devuelve:
    {:ok, {ciudades, rechazados_ciudades}, {movimientos, rechazados_movimientos}}
    {:error, [{ruta, motivo}, ...]}   si algún archivo no se pudo leer
  """

  def leer_archivos(ruta_ciudades, ruta_movimientos) do
    coordinador = self()

    spawn(fn -> trabajador(coordinador, :ciudades, ruta_ciudades) end)
    spawn(fn -> trabajador(coordinador, :movimientos, ruta_movimientos) end)

    {respuesta_ciudades, respuesta_movimientos} = esperar_respuestas(nil, nil)
    combinar_respuestas(respuesta_ciudades, respuesta_movimientos)
  end

  # Cada trabajador lee su archivo y envía al coordinador un mensaje con:
  # el tipo de archivo, la ruta y el resultado de la lectura (o el error).
  defp trabajador(coordinador, :ciudades, ruta) do
    resultado = Archivos.leer_ciudades(ruta)
    send(coordinador, {:archivo_procesado, :ciudades, ruta, resultado})
  end

  defp trabajador(coordinador, :movimientos, ruta) do
    resultado = Archivos.leer_movimientos(ruta)
    send(coordinador, {:archivo_procesado, :movimientos, ruta, resultado})
  end

  # Recibe mensajes de forma recursiva hasta tener la respuesta de los dos
  # trabajadores. No importa cuál llegue primero.
  # Se espera siempre a ambos (aunque uno falle) para que no quede ningún
  # mensaje pendiente en el buzón del coordinador.
  defp esperar_respuestas(respuesta_ciudades, respuesta_movimientos) do
    if respuesta_ciudades != nil and respuesta_movimientos != nil do
      {respuesta_ciudades, respuesta_movimientos}
    else
      receive do
        {:archivo_procesado, :ciudades, ruta, resultado} ->
          esperar_respuestas({ruta, resultado}, respuesta_movimientos)

        {:archivo_procesado, :movimientos, ruta, resultado} ->
          esperar_respuestas(respuesta_ciudades, {ruta, resultado})
      end
    end
  end

  defp combinar_respuestas({_, {:ok, datos_ciudades}}, {_, {:ok, datos_movimientos}}) do
    {:ok, datos_ciudades, datos_movimientos}
  end

  defp combinar_respuestas(respuesta_ciudades, respuesta_movimientos) do
    errores = obtener_error(respuesta_ciudades) ++ obtener_error(respuesta_movimientos)
    {:error, errores}
  end

  defp obtener_error({ruta, {:error, motivo}}), do: [{ruta, motivo}]
  defp obtener_error(_respuesta_exitosa), do: []
end
