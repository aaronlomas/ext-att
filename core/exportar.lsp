;;; core/exportar.lsp
;;; Exportación de datos seleccionados a un archivo CSV (separador ; ).

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
          (write-line "No.;Codigo_Poste;Estructura;descripcion;FAT;Coordenada_X;Coordenada_Y" fp)
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
            ;; Si es FAT, no se imprime coordenadas
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