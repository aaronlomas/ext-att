# extatt

Herramienta en AutoLISP que extrae atributos de bloques seleccionados y los exporta a un archivo CSV. DALE LIKE(ESTRELLA) AL PROYECTO CAUSA! 🤙

## Requisitos

- AutoCAD (cualquier versión con AutoLISP).
- No requiere librerías ni add-ons externos.

## Instalación

1. Descarga el **release** más reciente (el ZIP incluye).
2. Ejecuta el comando `APPLOAD`.
3. Selecciona `main_extatt.lsp` y pulsa **Cargar**.
4. Confirma con **Cerrar**.

> Para que se cargue automáticamente en cada sesión, añade el archivo a la lista de arranque (botón **Contenido…** de `APPLOAD`).

## Uso

1. Ejecuta el comando **`EXT-ATT`**.
2. Selecciona los bloques uno por uno, en el orden deseado.

   - Cada bloque seleccionado se registra y se muestra su número y código en la terminal.
   - Se dibuja en pantalla una **polilínea roja** que une los puntos en el orden de selección (clic 1 → clic 2 → clic 3 → …).

3. Para deshacer la última acción, escribe **`Z`** y pulsa Enter.

   - Elimina el ultimo bloque registrado de la seleccion y último vértice de la polilínea dibujada.

4. Pulsa **Enter** sin seleccionar nada o clic en vacío para terminar la selección y exportar.

## Archivo de salida

- Cada exportación genera un archivo nuevo y numerado: `data_extatt_01.csv`, `data_extatt_02.csv`, etc.
- Se guarda automáticamente en el **Escritorio** del usuario (`C:\Users\…\Desktop`), incluye el caso de Escritorio redirigido a OneDrive.
- Columnas: `No.;Codigo_Poste;Estructura;descripcion;FAT;Coordenada_X;Coordenada_Y`.
- Si el archivo está abierto en Excel, el programa lo indica y ofrece reintentar (`R`) o cancelar (`S`).

### Atributos exportados

| Columna        | Atributo del bloque |
| -------------- | ------------------- |
| Codigo_Poste   | `E-01` + `NUMERACION` |
| Estructura     | `SC/H=9M`           |
| descripcion   | `01/ELEC/--`        |
| FAT            | `FAT(01)`           |
| Coordenada_X/Y | Coordenadas del bloque (en blanco si solo tiene FAT) |

## Notas

- Funciona únicamente con bloques que contienen atributos `INSERT`.

## Estructura

| Archivo           | Responsabilidad                       |
| ----------------- | ------------------------------------- |
| `main_extatt.lsp` | Todo el código en un único archivo.   |
