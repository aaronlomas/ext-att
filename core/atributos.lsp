;;; core/atributos.lsp
;;; Utilidades generales y lectura de atributos de un bloque.

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