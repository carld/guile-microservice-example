(define app
  (resources
    ('GET '("hello")
       (lambda (params)
         (scm->json-string 
           (db-query 
             (format #f "SELECT * FROM hellotable LIMIT ~s OFFSET ~s"
               (or (params 'limit) 10)
               (or (params 'page) 0))))))
    ('GET '("hello2")
       (lambda (params)
         (format #f "HELLO WORLD!")))

 ))
