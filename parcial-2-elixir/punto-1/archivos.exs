defmodule Archivos do
  @moduledoc """
  Lectura de los archivos de entrada y escritura del reporte.

  leer_ciudades/1 y leer_movimientos/1 devuelven:
    {:ok, {registros_validos, cantidad_rechazados}}  o  {:error, motivo}
  """

  def leer_ciudades(ruta) do
    leer_registros(ruta, fn linea -> Validador.validar_ciudad(linea) end)
  end

  def leer_movimientos(ruta) do
    leer_registros(ruta, fn linea -> Validador.validar_movimiento(linea) end)
  end

  def guardar_reporte(ruta, texto) do
    File.write(ruta, texto)
  end

  defp leer_registros(ruta, funcion_validar) do
    case File.read(ruta) do
      {:ok, contenido} ->
        lineas = obtener_lineas_no_vacias(contenido)
        {:ok, clasificar(lineas, funcion_validar)}

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  # String.trim también quita el "\r" que dejan los archivos creados en Windows.
  defp obtener_lineas_no_vacias(contenido) do
    contenido
    |> String.split("\n")
    |> Enum.map(fn linea -> String.trim(linea) end)
    |> Enum.filter(fn linea -> linea != "" end)
  end

  # Recorre las líneas y separa los registros válidos de los rechazados.
  # Devuelve {lista_de_validos, cantidad_de_rechazados} conservando el orden del archivo.
  defp clasificar([], _funcion_validar), do: {[], 0}

  defp clasificar([linea | resto], funcion_validar) do
    {validos, rechazados} = clasificar(resto, funcion_validar)

    case funcion_validar.(linea) do
      {:ok, registro} -> {[registro | validos], rechazados}
      :error -> {validos, rechazados + 1}
    end
  end
end
