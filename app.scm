(use-modules (json)) ;  git@github.com:aconchillo/guile-json.git

(register-service
  ('GET '("hello")
     (lambda (params)
       (let ((limit (string->number (params 'limit "10")))
             (page  (string->number (params 'page "0"))))
       (scm->json-string 
         (db-query-log-time
           (format #f
             "SELECT * FROM hellotable LIMIT ~a OFFSET ~a"
             limit (* limit page))))))))

(register-service
  ('GET '("hello2")
     (lambda (params)
       (format #f "HELLO WORLD!"))))

