; Example JSON microservice rendering data from a SQLite database.
(use-modules (web server)) ; guile-web
(use-modules (web request)
             (web response)
             (web uri))
(use-modules (json))       ; git@github.com:aconchillo/guile-json.git
(use-modules (dbi dbi))    ; pacman -Sy guile-dbi  # Arch Linux
                           ; and also http://download.gna.org/guile-dbi/guile-dbd-sqlite3-2.1.6.tar.gz
(use-modules (ice-9 hash-table))

(define db-obj (dbi-open "sqlite3" "server-db"))

(define (request-path-components request)
    (split-and-decode-uri-path (uri-path (request-uri request))))

(define (request-query-components request)
  "This returns an association list given a query string.
    name1=value1&name2=value2  ->  ((name1 . \"value1\") (name2 . \"value2\"))
   The name in the name value pair is converted to a symbol.
   If there is no query string, return false."
  (let ((query (uri-query (request-uri request))))
    (if query
      (map (lambda (x) (let ((y (string-split x #\=)))
                         (cons (string->symbol (car y)) (car (cdr y)))))
        (filter (lambda (x) (not (string-null? x)))
                (map uri-decode (string-split query #\&))))
       #f )))

(define (db-query offset)
  (dbi-query db-obj 
     (format #f "SELECT * FROM hellotable LIMIT ~d OFFSET ~d" 10 offset))
  (let loop ((row (dbi-get_row db-obj))
             (results '()))
    (cond ((eq? row #f) (json (array ,results)))
          (else (loop (dbi-get_row db-obj) (cons (alist->hash-table row) results))))))

(define (not-found request)
  (values (build-response #:code 404)
          (string-append "Resource not found: "
                (uri->string (request-uri request)))))

(define (hello-hacker-handler request body)
  (let ((params (request-query-components request)))
  (format (current-output-port) "~s ~%" (request-query-components request))
  (cond 
    ((equal? (request-path-components request) '("hello"))  ; /hello
       (values '((content-type . (text/json)))
               (let ((results (db-query (string->number (assoc-ref params 'offset)))))
                  (scm->json-string results))))

    (else (not-found request)))))

(run-server hello-hacker-handler)  ; localhost:8080/hello?offset=1

(dbi-close db-obj)

