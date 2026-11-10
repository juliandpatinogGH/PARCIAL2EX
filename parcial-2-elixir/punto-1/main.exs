# Punto 1: reporte local de sismos.
# Ejecutar desde la carpeta punto-1:   elixir main.exs

Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("validador.exs", __DIR__)
Code.require_file("archivos.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)
Code.require_file("estadisticas.exs", __DIR__)
Code.require_file("procesador.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Aplicacion do
  @ruta_ciudades "resources/ciudades.txt"
  @ruta_movimientos "resources/movimientos.txt"
  @ruta_reporte "resources/reporte_sismos.txt"

  def generar_reporte do
    case Coordinador.leer_archivos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos_ciudades, datos_movimientos} ->
        datos = ProcesadorSismos.procesar(datos_ciudades, datos_movimientos)
        texto = Reporte.generar_general(datos)
        IO.puts(texto)
        guardar(texto)

      {:error, errores} ->
        IO.puts(Reporte.generar_errores(errores))
        IO.puts("No se generó el reporte. Se conserva el reporte anterior.")
    end
  end

  defp guardar(texto) do
    case Archivos.guardar_reporte(@ruta_reporte, texto) do
      :ok ->
        IO.puts("Reporte guardado en #{@ruta_reporte}")

      {:error, motivo} ->
        IO.puts("Error: no se pudo guardar el reporte en #{@ruta_reporte} (#{inspect(motivo)})")
    end
  end
end

Aplicacion.generar_reporte()
