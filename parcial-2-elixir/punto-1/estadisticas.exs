defmodule Estadisticas do
  @moduledoc """
  Calcula las estadísticas de los movimientos de una ciudad.

  calcular/1 recibe la lista de movimientos de UNA ciudad y devuelve un mapa:
    %{cantidad: entero, mayor: %Movimiento{} o nil, promedio: decimal o nil}
  """

  def calcular(movimientos) do
    {cantidad, mayor, suma_profundidades} = recorrer(movimientos, 0, nil, 0.0)

    %{
      cantidad: cantidad,
      mayor: mayor,
      promedio: calcular_promedio(suma_profundidades, cantidad)
    }
  end

  # Recursividad explícita: en un mismo recorrido se acumulan
  #   - cantidad: cuántos movimientos se han visto
  #   - mayor: el movimiento de mayor magnitud hasta el momento
  #   - suma: la suma de las profundidades
  defp recorrer([], cantidad, mayor, suma), do: {cantidad, mayor, suma}

  defp recorrer([movimiento | resto], cantidad, mayor, suma) do
    recorrer(
      resto,
      cantidad + 1,
      elegir_mayor(mayor, movimiento),
      suma + movimiento.profundidad
    )
  end

  # Se usa ">" (y no ">=") para que, si hay empate, se conserve el primero
  # que apareció en el archivo.
  defp elegir_mayor(nil, movimiento), do: movimiento

  defp elegir_mayor(mayor_actual, movimiento) do
    if movimiento.magnitud > mayor_actual.magnitud do
      movimiento
    else
      mayor_actual
    end
  end

  defp calcular_promedio(_suma, 0), do: nil
  defp calcular_promedio(suma, cantidad), do: suma / cantidad
end
