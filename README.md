# extatt

Herramienta en AutoLISP que extrae atributos de bloques seleccionados y los exporta a un archivo CSV compatible con Excel

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
2. Selecciona los bloques (postes) uno por uno, en el orden deseado.

   - Cada bloque seleccionado se registra y se muestra su número y código en la terminal.
   - Se dibuja en pantalla una **polilínea roja** que une los puntos en el orden de selección (clic 1 → clic 2 → clic 3 → …).
   - Si el bloque tiene atributo **FAT**, se dibuja un **círculo rojo** de radio 7.0 en su ubicación.

3. Para deshacer el último bloque, escribe **`Z`** y pulsa Enter.

   - Elimina el ultimo registro de seleccion y vértice de la polilínea.

4. Presiona la tecla **`1`** para sumar +10 a la **última fila con FAT** (solo afecta esa fila).

   - Primera pulsación: **IN** += 10
   - Segunda pulsación: **OUT** += 10
   - Tercera pulsación: **IN** += 10
   - (alterna IN → OUT → IN → …)

   - Si el último bloque no tiene FAT, muestra un aviso y no suma nada.

5. `Z` revierte la última acción y restaura el estado de la tecla **1** del registro eliminado.

6. Pulsa **Enter** sin seleccionar nada o clic en vacío para terminar la selección y exportar.

## Archivo de salida

- Cada exportación genera un archivo nuevo y numerado: `data_extatt_01.csv`, `data_extatt_02.csv`, etc.
- Se guarda automáticamente en el **Escritorio** del usuario (`C:\Users\…\Desktop`), incluye el caso de Escritorio redirigido a OneDrive.
- Columnas: `No.;Codigo_Poste;Estructura;descripcion;FAT;IN;OUT;Coordenada_X;Coordenada_Y`.
- Si el archivo está abierto en Excel, el programa lo indica y ofrece reintentar (`R`) o cancelar (`S`).

### Atributos exportados

| Columna        | Atributo del bloque / Función |
| -------------- | ----------------------------- |
| Codigo_Poste   | `E-01` + `NUMERACION` |
| Estructura     | `SC/H=9M`           |
| descripcion   | `01/ELEC/--`        |
| FAT            | `FAT(01)`           |
| IN             | Acumulador IN (tecla 1, solo en filas FAT) |
| OUT            | Acumulador OUT (tecla 1, solo en filas FAT) |
| Coordenada_X/Y | Coordenadas del bloque (en blanco si solo tiene FAT) |

## Notas

- Funciona únicamente con bloques que contienen atributos `INSERT`.
- Los círculos rojos se dibujan en la capa `EXT-ATT-CIRCLE`.
- La tecla **1** alterna entre IN y OUT; cada pulsación suma 10, solo en la última fila FAT.
- Sin FAT, las columnas IN y OUT quedan en 0.

## Estructura

| Archivo           | Responsabilidad                       |
| ----------------- | ------------------------------------- |
| `main_extatt.lsp` | Todo el código en un único archivo.   |