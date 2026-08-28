;;; seleccionar_bloques.lsp - Version v0.1.0
;;; Exportación directa y limpia a CSV separado por punto y coma (;) para Excel en español.
;;; Incluye opción de invalidar el último registro con la tecla Z.
;;; Ahora muestra en la terminal el último Value de E-01 seleccionado.

(defun SB:STR (v / )
  (cond
    ((= (type v) 'STR) v)
    ((numberp v) (rtos v 2 4))
    ((null v) "")
    (t "")
  )
)

(defun SB:GET-VAL-ATTR (ename tag / e d result encontrado)
  (setq result "" encontrado nil)
  (setq e (entnext ename))
  (while (and e (setq d (entget e)) (/= (cdr (assoc 0 d)) "SEQEND") (not encontrado))
    (if (= (cdr (assoc 0 d)) "ATTRIB")
      (if (= (strcase (cdr (assoc 2 d))) (strcase tag))
        (progn
          (setq result (cdr (assoc 1 d)))
          (setq encontrado t)
        )
      )
    )
    (setq e (entnext e))
  )
  result
)

(defun SB:CARPETA-DESTINO ( / shell desktop ruta dwg)
  ;;; Calcula la carpeta de salida de forma robusta:
  ;;; 1) WScript.Shell "Desktop" (maneja OneDrive/redirecciones),
  ;;; 2) USERPROFILE\Desktop,
  ;;; 3) directorio del dibujo actual,
  ;;; 4) directorio actual de trabajo.
  (vl-load-com)
  (setq ruta nil
        shell nil)
  (setq shell (vl-catch-all-apply 'vlax-create-object (list "WScript.Shell")))
  (if (and (not (vl-catch-all-error-p shell)) shell)
    (progn
      (setq desktop (vl-catch-all-apply 'vlax-invoke-property (list shell 'SpecialFolders "Desktop")))
      (if (and (not (vl-catch-all-error-p desktop)) desktop)
        (setq ruta desktop)
      )
      (vlax-release-object shell)
    )
  )
  (if (null ruta)
    (if (and (setq desktop (getenv "USERPROFILE")) (/= desktop ""))
      (setq ruta (strcat desktop "\\Desktop"))
    )
  )
  (if (null ruta)
    (if (and (setq dwg (getvar "DWGPREFIX")) (/= dwg ""))
      (setq ruta dwg)
    )
  )
  (if (and ruta (/= (substr ruta (strlen ruta)) "\\"))
    (setq ruta (strcat ruta "\\"))
  )
  ruta
)

(defun SB:ARCHIVO-NUEVO (carpeta / i archivo)
  ;;; primer archivo exportado: data_extatt_01.csv, _02, _03, ...
  (setq i 0)
  (while (progn
           (setq i (1+ i))
           (setq archivo (strcat carpeta "data_extatt_"
                          (if (< i 10) "0" "") (itoa i) ".csv"))
           ;;; el bucle continúa mientras el archivo ya exista
           (vl-file-size archivo)
         )
  )
  archivo
)

(defun SB:RUTA-CSV ( )
  ;;; Combina la carpeta de salida con el primer nombre de archivo libre.
  (SB:ARCHIVO-NUEVO (SB:CARPETA-DESTINO))
)

(defun SB:EXPORTAR (data-list / ruta fp idx item ename x y val-e val-sc val-elec val-num val-fat seguir)
  (if (and data-list (> (length data-list) 0))
    (progn
      (setq ruta (SB:RUTA-CSV))
      ;; Si el archivo está bloqueado (abierto en Excel), reintentar al presionar R
      (setq fp nil seguir "R")
      (while (and (eq seguir "R") (null fp))
        (setq fp (open ruta "w"))
        (if (null fp)
          (progn
            (princ (strcat "\n[ERROR] No se pudo escribir en:\n        " ruta "\n"))
            (princ "El archivo puede estar abierto en Excel.\n")
            (initget "S R")
            (setq seguir (getkword "Cerrar Excel y [R]eintentar, o [S]alir? "))
          )
        )
      )
      (if fp
        (progn
          (write-line "No.;Codigo_Poste;Estructura;Circuito;FAT;Coordenada_X;Coordenada_Y" fp)
          (setq idx 0)
          (foreach item data-list
            (setq idx (1+ idx))
            (setq ename (nth 0 item))
            (setq x (nth 2 item))
            (setq y (nth 3 item))
            (setq val-e    (SB:GET-VAL-ATTR ename "E-01"))
            (setq val-sc   (SB:GET-VAL-ATTR ename "SC/H=9M"))
            (setq val-elec (SB:GET-VAL-ATTR ename "01/ELEC/--"))
            (setq val-num  (SB:GET-VAL-ATTR ename "NUMERACION"))
            (setq val-fat  (SB:GET-VAL-ATTR ename "FAT(01)"))
            ;; Si es FAT solo, no imprimir coordenadas
            (if (and (= val-e "") (= val-sc "") (= val-elec "") (= val-num ""))
              (setq x "" y "")
            )
            (write-line
              (strcat (itoa idx) ";"
                      (SB:STR val-e)(SB:STR val-num) ";"
                      (SB:STR val-sc) ";"
                      (SB:STR val-elec) ";"
                      (SB:STR val-fat) ";"
                      (SB:STR x) ";"
                      (SB:STR y))
              fp)
          )
          (close fp)
          (princ "\n================================================")
          (princ "\n¡REPORTE GENERADO CON ÉXITO!")
          (princ (strcat "\nArchivo guardado en:\n        " ruta))
          (princ "\n================================================\n")
        )
        (princ "\nExportación cancelada. No se escribió nada.\n")
      )
    )
    (princ "\n[ERROR] Selección vacía. No se exportó nada.\n")
  )
  (princ)
)

(defun SB:PROCESAR (ename data-list / etype edata pt x y reg padre)
  (setq edata (entget ename))
  (setq etype (SB:STR (cdr (assoc 0 edata))))
  (if (= etype "ATTRIB")
    (progn
      (setq padre (cdr (assoc 330 edata)))
      (if padre (progn (setq ename padre) (setq edata (entget ename)) (setq etype (SB:STR (cdr (assoc 0 edata)))))))
  )
  (if (= etype "INSERT")
    (progn
      (setq pt (cdr (assoc 10 edata)))
      (setq x (if pt (car pt) 0.0))
      (setq y (if pt (cadr pt) 0.0))
      (setq reg (list ename "INSERT" x y))
    )
  )
  reg
)

(defun c:EXT-ATT ( / ent reg data-list total val-e)
  (setq data-list nil)
  (princ "\n------------------------------------------\n")
  (princ "  Extrae Values de bloques y se exporta a excel\n")
  (princ "  ENTER para terminar, Z para invalidar último.\n")
  (princ "--------------------------------------------\n\n")
  
  (while (progn
           (initget "Z")
           (setq ent (entsel "\nSeleccione un bloque o [Z] para Deshacer: "))
        )
    (if (= ent "Z")
      ;; Invalida el último registro mostrando índice y bloque
      (if data-list
        (progn
          (setq last (car (reverse data-list)))        ; último registro
          (setq idx (length data-list))                ; índice actual
          (setq val-e (SB:GET-VAL-ATTR (car last) "E-01"))
          (setq val-num (SB:GET-VAL-ATTR (car last) "NUMERACION"))
          (setq val-fat (SB:GET-VAL-ATTR (car last) "FAT(01)"))
          (princ (strcat "- Eliminado: #" (itoa idx)
                         " - BLQ: " (SB:STR val-e)(SB:STR val-num)(SB:STR val-fat) "\n"))
          ;; quitar último registro
          (setq data-list (reverse (cdr (reverse data-list))))
          (setq total (length data-list))
        )
        (princ "\nNo hay registros para eliminar.\n")
      )
      ;; Caso normal: registrar bloque
      (progn
        (setq reg (SB:PROCESAR (car ent) data-list))
        (if reg
          (progn
            (setq data-list (append data-list (list reg)))
            (setq total (length data-list))
            ;; Mostrar número y último Value de E-01
            (setq val-e (SB:GET-VAL-ATTR (car reg) "E-01"))
            (setq val-num (SB:GET-VAL-ATTR (car reg) "NUMERACION"))
            (setq val-fat (SB:GET-VAL-ATTR (car reg) "FAT(01)"))
            (princ (strcat "#" (itoa total)
                           " -> BLQ: " (SB:STR val-e)(SB:STR val-num)(SB:STR val-fat) "\n"))
          )
          (princ "\n[ERROR] Selección inválida.\n")
        )
      )
    )
  )
  
  ;; Exportar si hay datos
  (if (and data-list (> (length data-list) 0))
    (SB:EXPORTAR data-list)
    (princ "\n[ERROR] Selección vacía. No se exportó nada.\n")
  )
  
  (princ)
)
