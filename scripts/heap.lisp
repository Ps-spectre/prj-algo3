
(defun hparent (i)
  (floor (- i 1) 2))

(defun hright (i)
  (* (+ i 1) 2))

(defun hleft (i)
  (- (hright i) 1))

(defun draw-heap (vec)
  (format t "~%")
  (let ((h (+ 1 (floor (log (length vec) 2)))))
    (dotimes (i h)
      (let ((spaces (loop :repeat (- (expt 2 (- h i)) 1) :collect #\Space)))
        (dotimes (j (expt 2 i))
          (let ((k (+ (expt 2 i) j -1)))
            (when (= k (length vec)) (return))
            (format t "~{~C~}~2D~{~C~}" spaces (aref vec k) spaces)))
        (format t "~%"))))
  (format t "~%")
  vec)

(defun check-heap (vec &key (key '>))
  (dotimes (i (ash (length vec) -1))
    (when (= (hleft i) (length vec)) (return))
    (assert (not (funcall key (aref vec (hleft i)) (aref vec i)))
            ()
            "Left child (~A) is ~A than parent at ~A (~A)."
            (aref vec (hleft i)) key i (aref vec i))
    (when (= (hright i) (length vec)) (return))
    (assert (not (funcall key (aref vec (hright i)) (aref vec i)))
            ()
            "Right child (~A) is ~A than parent at ~A (~A)."
            (aref vec (hright i)) key i (aref vec i)))
  vec)

(defun build-heap (vec)
  (let ((mid (floor (length vec) 2)))
    (dotimes (i mid)
      (heap-down vec (- mid i 1))))
  vec)

(defun heap-up (vec i)
  (when (> (aref vec i) (aref vec (hparent i)))
    (rotatef (aref vec i) (aref vec (hparent i)))
    (heap-up vec (hparent i)))
  vec)

(defun heap-down (vec beg &optional (end (- (length vec) 1)))
  (when (< (hleft beg) end)
    (let ((child (if (or (>= (hright beg) end)
                         (> (aref vec (hleft i))
                            (aref vec (hright i))))
                     (hleft beg)
                     (hright beg))))
      (when (> (aref vec child) (aref vec beg))
        (rotatef (aref vec beg) (aref vec child))
        (heap-down vec child end))))
  vec)

(defun heap-push (node vec)
  (vector-push-extend node vec)
  (heap-up vec (1- (length vec))))

(defun heap-pop (vec)
  (rotatef (aref vec 0) (aref vec (- (length vec) 1)))
  (let ((rez (vector-pop vec)))
    (heap-down vec)
    rez))
