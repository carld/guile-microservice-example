(define-module (utils)
  #:use-module (srfi srfi-19)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web uri)
  #:export (time log-common))

(define-syntax time
  (syntax-rules()
    ((_ exp)
     (let* ((st (times))
            (result exp)
            (et (times)))
        (values
          result
          (/ (- (tms:clock et) (tms:clock st)) internal-time-units-per-second))))))

;(define (fibonacci x)
;  (cond ((eq? x 0) 0)
;        ((eq? x 1) 1)
;        (else (+ (fibonacci (- x 1))
;                 (fibonacci (- x 2))))))
;
;(call-with-values (lambda () (time (fibonacci 35)))
;                  (lambda (x y)
;                    (format #t "~a ~f ~%" x y)))

(define (log-common req timestamp status-code content-length)
  (format #t "~a ~a ~a [~a] \"~a\" ~a ~a~%"
    (car (request-host req))
    "-"
    "-"
    (date->string timestamp "~d/~b/~Y:~k:~M:~S ~z")
    (format #f "~a ~a ~a ~a"
      (request-method req)
      (uri-path (request-uri req))
      (uri-query (request-uri req))
      (format #f "/HTTP ~d.~d" (car (request-version req)) (cdr (request-version req))))
    status-code
    content-length))
