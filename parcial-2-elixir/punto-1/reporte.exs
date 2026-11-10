defmodule Reporte do
  @moduledoc """
  Construye el texto de los reportes a partir de los datos de ProcesadorSismos.
  Este módulo no lee archivos ni imprime: solo arma cadenas de texto.
  """

  @linea_doble "=================================================="
  @linea_simple "--------------------------------------------------"

  def generar_general(datos) do
    encabezado = [@linea_doble, "        REPORTE DE SISMOS POR CIUDAD", @linea_doble, ""]
    bloques_ciudades = Enum.map(datos.ciudades, fn resumen -> texto_ciudad(resumen) end)

    rechazados = [
      "REGISTROS RECHAZADOS",
      "  ciudades.txt: #{datos.rechazados_ciudades}",
      "  movimientos.txt: #{datos.rechazados_movimientos}",
      @linea_doble
    ]

    Enum.join(encabezado ++ bloques_ciudades ++ rechazados, "\n") <> "\n"
  end

  def generar_ciudad(datos, id_ciudad) do
    case ProcesadorSismos.buscar_ciudad(datos, id_ciudad) do
      nil -> "REPORTE DE LA CIUDAD #{id_ciudad}\nLa ciudad no está registrada\n"
      resumen -> "REPORTE DE LA CIUDAD #{id_ciudad}\n" <> texto_ciudad(resumen)
    end
  end

  def generar_errores(errores) do
    lineas =
      Enum.map(errores, fn {ruta, motivo} ->
        "Error: no se pudo leer el archivo #{ruta} (#{inspect(motivo)})"
      end)

    Enum.join(lineas, "\n")
  end

  defp texto_ciudad(resumen) do
    ciudad = resumen.ciudad
    estadisticas = resumen.estadisticas

    lineas = [
      "Ciudad: #{ciudad.nombre} (#{ciudad.id})",
      "Habitantes: #{ciudad.habitantes}",
      "Movimientos:"
    ]

    lineas =
      lineas ++
        texto_movimientos(resumen.movimientos) ++
        [
          "Total de movimientos: #{estadisticas.cantidad}",
          "Movimiento de mayor magnitud: #{texto_mayor(estadisticas.mayor)}",
          "Profundidad promedio: #{texto_promedio(estadisticas.promedio)}",
          @linea_simple
        ]

    Enum.join(lineas, "\n") <> "\n"
  end

  defp texto_movimientos([]), do: ["  Sin movimientos registrados"]

  defp texto_movimientos(movimientos) do
    Enum.map(movimientos, fn movimiento ->
      "  - #{movimiento.codigo} | Inicio: #{movimiento.hora_inicio}" <>
        " | Final: #{movimiento.hora_final}" <>
        " | Magnitud: #{movimiento.magnitud}" <>
        " | Profundidad: #{movimiento.profundidad} km"
    end)
  end

  defp texto_mayor(nil), do: "No aplica"
  defp texto_mayor(movimiento), do: "#{movimiento.codigo} - magnitud #{movimiento.magnitud}"

  defp texto_promedio(nil), do: "No aplica"
  defp texto_promedio(promedio), do: "#{dos_decimales(promedio)} km"

  defp dos_decimales(numero) do
    :erlang.float_to_binary(numero, decimals: 2)
  end
end
