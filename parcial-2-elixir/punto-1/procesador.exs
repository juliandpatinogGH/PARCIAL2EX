defmodule ProcesadorSismos do
  @moduledoc """
  Une las ciudades con sus movimientos y calcula las estadísticas de cada una.

  procesar/2 recibe lo que devolvió el Coordinador:
    {ciudades, rechazados_ciudades} y {movimientos, rechazados_movimientos}

  y devuelve un mapa con:
    ciudades: lista de %{ciudad: ..., movimientos: [...], estadisticas: %{...}}
    rechazados_ciudades: entero
    rechazados_movimientos: entero (incluye los movimientos de ciudades inexistentes)
  """

  def procesar({ciudades, rechazados_ciudades}, {movimientos, rechazados_movimientos}) do
    ids_validos = Enum.map(ciudades, fn ciudad -> ciudad.id end)
    sin_ciudad = contar_sin_ciudad(movimientos, ids_validos)

    %{
      ciudades: Enum.map(ciudades, fn ciudad -> resumen_ciudad(ciudad, movimientos) end),
      rechazados_ciudades: rechazados_ciudades,
      rechazados_movimientos: rechazados_movimientos + sin_ciudad
    }
  end

  # Busca el resumen de una ciudad por su id. Devuelve nil si no está registrada.
  def buscar_ciudad(datos, id_ciudad) do
    Enum.find(datos.ciudades, fn resumen -> resumen.ciudad.id == id_ciudad end)
  end

  defp resumen_ciudad(ciudad, movimientos) do
    movimientos_ciudad = movimientos_de_ciudad(movimientos, ciudad.id)

    %{
      ciudad: ciudad,
      movimientos: movimientos_ciudad,
      estadisticas: Estadisticas.calcular(movimientos_ciudad)
    }
  end

  # Enum.filter conserva el orden del archivo, necesario para el caso de empate.
  defp movimientos_de_ciudad(movimientos, id_ciudad) do
    Enum.filter(movimientos, fn movimiento -> movimiento.id_ciudad == id_ciudad end)
  end

  # Movimientos válidos en formato pero cuyo idCiudad no está en el catálogo.
  # Solo llegan aquí líneas con formato correcto, así que no se cuentan dos veces.
  defp contar_sin_ciudad(movimientos, ids_validos) do
    movimientos
    |> Enum.filter(fn movimiento -> not Enum.member?(ids_validos, movimiento.id_ciudad) end)
    |> length()
  end
end
