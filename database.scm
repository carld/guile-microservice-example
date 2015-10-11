(use-modules (dbi dbi))    ; pacman -Sy guile-dbi  # Arch Linux
                           ; and also http://download.gna.org/guile-dbi/guile-dbd-sqlite3-2.1.6.tar.g

(define db-obj (dbi-open "sqlite3" "server-db"))
;(define db-obj (dbi-open "postgresql" "carl::work:tcp:localhost:5432"))
(format #t "~a ~%" db-obj)

(define (db-query-log-time sql)
  (call-with-values (lambda () (time (db-query sql)))
                    (lambda (results elapsed-seconds)
                      (format #t "SQL: \"~a\" ~fms ~%" sql (* elapsed-seconds 1000))
                      results)))

(define (db-query sql)
  "sql query results are returned as a list of hash tables."
  "this procedure is tail recursive"
 (dbi-query db-obj sql)
 (let loop ((row (dbi-get_row db-obj))
            (results '()))
     (if (not (eq? 0 (car (dbi-get_status db-obj))))
       (format #t "Error: ~a ~a ~%" (car (dbi-get_status db-obj)) (cdr (dbi-get_status db-obj))))
     (cond
       ((eq? row #f)
        (json (array ,results)))
     (else (loop (dbi-get_row db-obj) (cons (alist->hash-table row) results))))))
