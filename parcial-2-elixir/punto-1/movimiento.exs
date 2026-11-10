defmodule Movimiento do
  @moduledoc """
  Representa un movimiento sísmico (archivo resources/movimientos.txt).
  Las horas se guardan como texto "HH:MM:SS" ya validado.
  La magnitud y la profundidad se guardan como números decimales.
  """
  defstruct codigo: "",
            id_ciudad: "",
            hora_inicio: "",
            hora_final: "",
            magnitud: 0.0,
            profundidad: 0.0
end
