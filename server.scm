; Example JSON microservice rendering data from a SQLite database.
(use-modules (web server)) ; guile-web
(use-modules (web request)
             (web response)
             (web uri))
(use-modules (srfi srfi-19))

(add-to-load-path (dirname (current-filename))) ; temporary while my module is a work in progress

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

(define-syntax canned-response
  (syntax-rules ()
    ((_ name status-code body)
       (define (name req)
        (let ((content body))
          (log-common req (current-date) status-code (string-length body))
          (values (build-response #:code status-code)
                  body))))))

(canned-response not-allowed 405 "method not allowed")
(canned-response not-found   404 "resource not found")

(define handler-list (list))

(define-syntax register-service
  (syntax-rules ()
    ((_ (defined-method defined-path content-thunk))
        (let ((service (list defined-method defined-path content-thunk)))
          (set! handler-list (append handler-list (list service)))))))

(define (dispatch handler req)
  (cond ((equal? (request-method req) (car handler))
          (let ((content ((caddr handler) (make-params req))))
             (log-common req (current-date) 200 (string-length content))
             (values '((content-type . (text/json))) content)))
        (else (not-allowed))))

(define (dispatcher req body)
  (let ((handler (filter (lambda (h) (equal? (cadr h) (request-path-components req)))
                          handler-list)))
    (cond ((pair? handler)
            (dispatch (car handler) req))
          (else (not-found)))))

(load "database.scm")
(load "app.scm")

(run-server dispatcher)  ; localhost:8080/hello?offset=1

(dbi-close db-obj)
