;;; core/procesar.lsp
;;; Conversión de la entidad seleccionada en un registro de datos:
;;; ename, tipo, coordenadas de inserción (para el CSV) y punto del clic
;;; (para la polilínea).

(defun SB:PROCESAR (ename pick / etype edata pt x y px py reg padre)
  (setq px (if pick (car pick) nil)
        py (if pick (cadr pick) nil))
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
      ;; reg: ename, tipo, inserción x/y (para el CSV), clic x/y (para la polilínea)
      (setq reg (list ename "INSERT" x y px py))
    )
  )
  reg
)