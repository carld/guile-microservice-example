; Example JSON microservice rendering data from a SQLite database.
(use-modules (web server)) ; guile-web
(use-modules (web request)
             (web response)
             (web uri))
(use-modules (json))       ; git@github.com:aconchillo/guile-json.git
(use-modules (dbi dbi))    ; pacman -Sy guile-dbi  # Arch Linux
                           ; and also http://download.gna.org/guile-dbi/guile-dbd-sqlite3-2.1.6.tar.gz
(use-modules (ice-9 hash-table))
(use-modules (srfi srfi-19))

;(use-syntax (ice-9 syncase))  ; deprecated

(use-modules (system vm trace))

(add-to-load-path (dirname (current-filename))) ; temporary

(format #t "~s ~%" %load-path)

(use-modules (utils ))  ; my library code


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

(define (make-params request)
  (lambda (arg default)
    (let ((params (request-query-components request)))
      (or (assoc-ref params arg) default))))

(define (log-common req s l)
  (format (current-output-port) "~a ~a ~a [~a] \"~a\" ~a ~a~%"
          (car (request-host req)) "-" "-"
          (date->string (current-date) "~d/~b/~Y:~k:~M:~S ~z")
          (format #f "~a ~a?~a ~a"
                  (request-method req)
                  (uri-path (request-uri req))
                  (uri-query (request-uri req))
                  (format #f "/HTTP ~d.~d" (car (request-version req)) (cdr (request-version req))))
          s l))

(define-syntax canned-response
  (syntax-rules ()
    ((_ name status-code body)
       (define (name req)
        (let ((content body))
          (log-common req status-code (string-length body))
          (values (build-response #:code status-code)
                  body))))))

(canned-response not-allowed 405 "method not allowed")
(canned-response not-found   404 "resource not found")

(define-syntax resources
  (syntax-rules ()
    ((_ (defined-method defined-path content-thunk) ...)
      (lambda (request body)
        (let ((params (make-params request))
              (path   (request-path-components request))
              (method (request-method request)))
          (cond
            ((equal? defined-path path) 
              (if (equal? defined-method method)
                (let ((content (content-thunk params)))
                  (log-common request 200 (string-length content))
                  (values '((content-type . (text/json))) content) )
                (not-allowed request)))
            ...
            (else (not-found request))))))))

(load "database.scm")
(load "app.scm")

(run-server app)  ; localhost:8080/hello?offset=1

(dbi-close db-obj)

