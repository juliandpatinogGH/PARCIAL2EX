defmodule Validador do
  @moduledoc """
  Convierte una línea de texto en un struct.
  Si la línea es válida devuelve {:ok, struct}; si no, devuelve :error.
  """

  # Formato: idCiudad@nombre@numeroHabitantes
  def validar_ciudad(linea) do
    case separar_campos(linea) do
      [id, nombre, habitantes_texto] ->
        habitantes = convertir_entero(habitantes_texto)

        cond do
          id == "" or nombre == "" -> :error
          habitantes == nil -> :error
          habitantes <= 0 -> :error
          true -> {:ok, %Ciudad{id: id, nombre: nombre, habitantes: habitantes}}
        end

      _ ->
        :error
    end
  end

  # Formato: código@idCiudad@horaInicio@horaFinal@magnitud@profundidad
  def validar_movimiento(linea) do
    case separar_campos(linea) do
      [codigo, id_ciudad, hora_inicio, hora_final, magnitud_texto, profundidad_texto] ->
        magnitud = convertir_decimal(magnitud_texto)
        profundidad = convertir_decimal(profundidad_texto)

        cond do
          codigo == "" or id_ciudad == "" -> :error
          not hora_valida?(hora_inicio) -> :error
          not hora_valida?(hora_final) -> :error
          magnitud == nil -> :error
          profundidad == nil -> :error
          profundidad < 0 -> :error
          true ->
            {:ok,
             %Movimiento{
               codigo: codigo,
               id_ciudad: id_ciudad,
               hora_inicio: hora_inicio,
               hora_final: hora_final,
               magnitud: magnitud,
               profundidad: profundidad
             }}
        end

      _ ->
        :error
    end
  end

  # Una hora es válida si tiene la forma HH:MM:SS con HH entre 00 y 23
  # y MM, SS entre 00 y 59.
  def hora_valida?(texto) do
    case String.split(texto, ":") do
      [horas, minutos, segundos] ->
        parte_valida?(horas, 23) and parte_valida?(minutos, 59) and parte_valida?(segundos, 59)

      _ ->
        false
    end
  end

  defp parte_valida?(parte, maximo) do
    if byte_size(parte) == 2 and
         Enum.all?(:binary.bin_to_list(parte), fn digito -> digito >= ?0 and digito <= ?9 end) do
      String.to_integer(parte) <= maximo
    else
      false
    end
  end

  # Devuelve el número decimal o nil si el texto no es un decimal completo.
  # Ejemplo: "3.4" -> 3.4, "3" -> 3.0, "3.4abc" -> nil
  def convertir_decimal(texto) do
    case Float.parse(texto) do
      {numero, ""} -> numero
      _ -> nil
    end
  end

  # Devuelve el número entero o nil si el texto no es un entero completo.
  def convertir_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> numero
      _ -> nil
    end
  end

  defp separar_campos(linea) do
    linea
    |> String.split("@")
    |> Enum.map(fn campo -> String.trim(campo) end)
  end
end
