;;; core/polilinea.lsp
;;; Dibujo de polilínea roja.

(defun SB:CAPLINA ( / nombre ed c)
  (setq nombre "EXT-ATT-PLINE")
  (if (null (tblsearch "LAYER" nombre))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 nombre)
                   '(70 . 0)
                   '(62 . 1)
                   '(6 . "Continuous")))
    (progn
      (setq ed (entget (tblobjname "LAYER" nombre)))
      (if (/= (abs (if (setq c (cdr (assoc 62 ed))) c 0)) 1)
        (progn
          (setq ed (subst '(62 . 1) (assoc 62 ed) ed))
          (entmod ed)
        )
      )
    )
  )
)

(defun SB:DIBUJAR-PLINE (data-list pline / pts n ed aux px py)
  ;;; Dibuja/actualiza la polilínea roja, se crea con entmake (ename vía entlast) y luego se
  ;;; modifica EN SITIO con entmod/entupd al añadir o deshacer clics.
  (SB:CAPLINA)
  (setq pts nil)
  (foreach reg data-list
    (setq px (nth 4 reg)
          py (nth 5 reg))
    ;; si no hay clic registrado, usa el centro del bloque
    (if (null px) (setq px (nth 2 reg)))
    (if (null py) (setq py (nth 3 reg)))
    (setq pts (cons (list 10 px py) pts))
  )
  (setq pts (reverse pts))
  (setq n (length pts))
  (if (> n 1)
    (if (and pline (= (type pline) 'ENAME) (entget pline))
      (progn
        ;; actualiza vértices conservando su orden
        (setq ed (entget pline)
              aux nil)
        (foreach g ed
          (if (/= (car g) 10)
            (setq aux (cons g aux))
          )
        )
        (setq ed (append (reverse aux) pts))
        (setq ed (subst (cons 90 n) (assoc 90 ed) ed))
        (entmod ed)
        (entupd pline)
        pline
      )
      (progn
        ;; crear la polilínea y toma su ename con entlast
        (entmake
          (append
            (list '(0 . "LWPOLYLINE")
                  '(100 . "AcDbEntity")
                  '(100 . "AcDbPolyline")
                  '(70 . 0)
                  '(62 . 1)
                  (cons 90 n)
                  (cons 8 "EXT-ATT-PLINE"))
            pts
          )
        )
        (entlast)
      )
    )
    (progn
      ;; 0 o 1 clic: quitar la polilínea de la sesión
      (if (and pline (= (type pline) 'ENAME) (entget pline))
        (entdel pline)
      )
      nil
    )
  )
)