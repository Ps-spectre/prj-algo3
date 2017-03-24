;;;;
;;;; lab 01 for Advanced Algo course
;;;; second iteration -- more efficient algo
;;;; made by Andrew Kishchenko
;;;;

(defconstant +dfile+ "lab01_dict")

(defconstant +maxwordlen+ 24)

;;; key -> word, value -> freq
(defparameter *ngram* (make-hash-table :size 1000000 :test 'equal))
;;; key -> word word, value -> freq
(defparameter *ngram2* (make-hash-table :size 1000000 :test 'equal))
;;; our broken text without whitespaces (getting from STDIN)
(defparameter *text* nil)
;;; tree path
(defparameter *tree* (make-hash-table))

;;; Debug snippets
(defun pr (a) (format t "~a~%" a))
(defun pr2 (a b) (format t "~a~a~%" a b))
(defun prt (a) (format t "type is ~a, value is ~a~%" (type-of a) a))

;;; add parsed ngram to hashtable
(defun add-ngram (word freq ht)
  ;; (setf freq (floor freq 10000))
  (setf (gethash word ht) freq))

;;; parse ngram, format: word[tab]frequency
(defun parse-ngram (line ht)
  (dotimes (i (length line))
    (when (char-equal (char line i) #\Tab)
      (add-ngram (subseq line 0 i)(parse-integer (subseq line i (length line))) ht))))

;;; read file with ngrams
(defun fill-ngram(fname ht)
  (let ((in (open fname :if-does-not-exist nil)))
    (when in
      (loop for line = (read-line in nil)
            while line do (parse-ngram line ht)))
    (close in))
  (pr " read -> parse finish"))

;;;
;;; Hashtable helpers
;;;
(defun print-dict-kvp (key value)
  (format t "~a -> ~a~%" key value))

(defun print-ht-debug(ht)
  (with-hash-table-iterator (i ht)
    (loop (multiple-value-bind (entry-p key value) (i)
        (if entry-p
            (print-dict-kvp key value)
          (return))))))

;;; read text from stdin
;;; assume than in input "ourtextwithoutspaces" and double quotes surrounding
(defun read-text ()
  (setf *text* (read)))

(defun parse-text()
  (let ((tree ()))
    (get-words *tree* *text* 0 nil)
    (get-all-path *tree* 0 0 (make-array 32767))))

(defun freqp (seq)
  (let ((freq (gethash seq *ngram*)))
    (if (not freq) 0 freq)))

(defun concat2 (seq prevSeq)
  (concatenate 'string prevSeq " " seq))

(defun freqp2 (seq prevSeq)
  (let ((freq (gethash (concat2 seq prevSeq) *ngram2*)))
    (if (not freq) 0 freq)))

(defun wordp (seq prevSeq)
  (if (> (freqp seq) 0) t nil))
  ;; (if (not prevSeq)
  ;;   (if (> (freqp seq) 0) t nil)
  ;;   (if (> (freqp2 seq prevSeq) 0) t nil)))

(defun valid-len (txt i)
  (if (< i (length txt)) t nil))

(defun max-bounds (st txt)
  (min (length txt) (+ st +maxwordlen+)))

(defun get-words (ht txt start prevSeq)
  (let ((st (+ start 1)))
    (when (valid-len txt start)
      (let ((end (max-bounds st txt)))
        (loop for i from st to end
              do (collect-word ht prevSeq (subseq txt start i) i txt))))))

(defun collect-word (ht prevSeq seq index txt)
  (when (wordp seq prevSeq)
    (setf (gethash index ht) (cons (freqp2 seq prevSeq) (make-hash-table)))
    (get-words (cdr (gethash index ht)) txt index seq)))

;;; debug method, print path
(defun get-prev-depth (arr n)
  (dotimes (i n)
    (format t "~a " (car (aref arr i))))
  (format t "~%"))

(defun get-prev-cost (arr n)
  (let ((sum 0))
    (dotimes (i n)
      (setf sum (+ sum (cdr (aref arr i)))))
    (format t " (cost: ~a)" sum)))

;;; print fixed text
;;; array - (cons index . cost)
(defun print-fixed-text (pos spacepos text arr n)
  (when (< pos (length text))
    (when (eql pos (car (aref arr spacepos)))
      (format t " ")
      (when (< spacepos n)
        (setf spacepos (+ 1 spacepos))))
    (format t "~a" (char text pos))
    (print-fixed-text (+ pos 1) spacepos text arr n)))

;;; array - (cons index . cost)
(defun get-all-path(ht key d arr)
  (if (> (hash-table-count ht) 0)
    (with-hash-table-iterator (iter ht)
      (loop (multiple-value-bind (entry-p key value) (iter)
        (if entry-p
          (progn (setf (aref arr d) (cons key (car (gethash key ht)))) (get-all-path (cdr (gethash key ht)) key (+ d 1) arr))
          (return)))))
    (progn (print-fixed-text 0 0 *text* arr d) (get-prev-cost arr d) (format t "~%"))))

;;;
;;; main
;;;
(defun my-main()
  (fill-ngram "count_1w.txt" *ngram*)
  (fill-ngram "count_2w.txt" *ngram2*)
  (read-text)
  (parse-text))

(my-main)
