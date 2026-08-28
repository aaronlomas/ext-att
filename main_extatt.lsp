;;; main_extatt.lsp - Version v0.1.0

(defun SB:CARGAR-MODULO (modulo / archivo)
  ;;; Busca y carga core\<modulo>.lsp
  (setq archivo
    (or
      (findfile (strcat "core/" modulo ".lsp"))
      (findfile (strcat "core\\" modulo ".lsp"))
      (findfile (strcat "./core/" modulo ".lsp"))
    )
  )
  (if archivo
    (load archivo)
    (princ (strcat "\n[ERROR] No se encuentra core/" modulo ".lsp"))
  )
)

(foreach modulo '("atributos" "rutas" "exportar" "polilinea" "procesar")
  (SB:CARGAR-MODULO modulo)
)

(defun c:EXT-ATT ( / ent reg data-list total val-e val-num val-fat last idx pline)
  (setq data-list nil pline nil)
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
          ;; quita el último registro y redibujar la polilínea sin el último tramo
          (setq data-list (reverse (cdr (reverse data-list))))
          (setq total (length data-list))
          (setq pline (SB:DIBUJAR-PLINE data-list pline))
        )
        (princ "\nNo hay registros para eliminar.\n")
      )
      ;; Caso normal: registrar bloque
      (progn
        (if (= (cdr (assoc 0 (entget (car ent)))) "LWPOLYLINE")
          ;; La polilínea roja intercepta el clic: re-preguntar sin fallar
          (princ "\nEvite la polilínea roja: pulse sobre el bloque.\n")
          (progn
            (setq reg (SB:PROCESAR (car ent) (cadr ent)))
            (if reg
              (progn
                (setq data-list (append data-list (list reg)))
                (setq total (length data-list))
                ;; Dibuja polilínea roja con los puntos del clic en orden
                (setq pline (SB:DIBUJAR-PLINE data-list pline))
                ;; Muestra número y último Value de E-01
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
    )
  )

  ;; Exportar si hay datos
  (if (and data-list (> (length data-list) 0))
    (SB:EXPORTAR data-list)
    (princ "\n[ERROR] Selección vacía. No se exportó nada.\n")
  )

  (princ)
)