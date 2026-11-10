# Parcial II – Programación 3 (Elixir)

Observatorio Sismológico de la Universidad del Quindío.

## Punto 1 – Reporte local

Carpeta desde la que se ejecuta: `punto-1`

```
cd punto-1
elixir main.exs
```

- Archivos de entrada: `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`
- Reporte generado: `punto-1/resources/reporte_sismos.txt`

## Punto 2 – Consulta entre nodos

Se usan dos terminales. Primero se inicia el servidor y luego el cliente.

- Nombre del nodo servidor: `servidor`
- Nombre del nodo cliente: `cliente`
- Cookie: `sismos`. Cada programa inicia su nodo y configura la misma cookie automáticamente (archivo `punto-2/nodo.exs`).

**Terminal 1 – Servidor.** Carpeta: `punto-2/nodo-servidor`

```
cd punto-2/nodo-servidor
elixir servidor.exs
```

**Terminal 2 – Cliente.** Carpeta: `punto-2/nodo-cliente`

```
cd punto-2/nodo-cliente
elixir cliente.exs
```

También funcionan con el nombre y la cookie escritos en el comando:
`elixir --sname servidor --cookie sismos servidor.exs` y `elixir --sname cliente --cookie sismos cliente.exs`

## Verificación del punto 2

Identificadores usados:

- Ciudad con movimientos: `C01` (Armenia)
- Ciudad sin movimientos: `C03` (Circasia)
- Ciudad inexistente: `C99`

Para ejecutar el cliente por segunda vez con el mismo servidor, deje abierta la Terminal 1 y, cuando el cliente termine, vuelva a ejecutar en la Terminal 2 (carpeta `punto-2/nodo-cliente`):

```
elixir cliente.exs
```

## Reflexión sobre el uso de inteligencia artificial

Ver el archivo [reflexion_ia.pdf](reflexion_ia.pdf).
