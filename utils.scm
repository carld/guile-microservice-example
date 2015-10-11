(define-module (utils))

(export time)

(define-syntax time
  (syntax-rules()
    ((_ exp)
     (let* ((st (times))
            (result exp)
            (et (times)))
        (values
          result
          (/ (- (tms:clock et) (tms:clock st)) internal-time-units-per-second))))))

(define (fibonacci x)
  (cond ((eq? x 0) 0)
        ((eq? x 1) 1)
        (else (+ (fibonacci (- x 1))
                 (fibonacci (- x 2))))))

;(call-with-values (lambda () (time (fibonacci 35)))
;                  (lambda (x y)
;                    (format #t "~a ~f ~%" x y)))
