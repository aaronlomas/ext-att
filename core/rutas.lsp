;;; core/rutas.lsp
;;; Cálculo de la carpeta de salida (sin ActiveX) y del primer nombre de
;;; archivo CSV libre: data_extatt_01.csv, _02, _03, ...

(defun SB:CARPETA-DESTINO ( / up od dwg cand ruta)
  (setq up (getenv "USERPROFILE")
        od (getenv "OneDrive")
        ruta nil)
  (setq cand (list
               (if up (strcat up "\\Desktop") nil)
               (if od (strcat od "\\Desktop") nil)
               (if up (strcat up "\\OneDrive\\Desktop") nil)
             )
  )
  (foreach c cand
    (if (and (null ruta) c (findfile (strcat c "\\")))
      (setq ruta (strcat c "\\"))
    )
  )
  ;; si ninguno confirmó existencia, usa el Desktop habitual igualmente
  (if (null ruta)
    (if (and up (/= up ""))
      (setq ruta (strcat up "\\Desktop\\"))
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
  (setq i 0)
  (while (progn
           (setq i (1+ i))
           (setq archivo (strcat carpeta "data_extatt_"
                          (if (< i 10) "0" "") (itoa i) ".csv"))
           ;;; continúa mientras el archivo ya exista
           (findfile archivo)
         )
  )
  archivo
)

(defun SB:RUTA-CSV ( )
  ;;; Combina la carpeta de salida con el primer nombre de archivo libre.
  (SB:ARCHIVO-NUEVO (SB:CARPETA-DESTINO))
)