(define memory
    (let ((table '()))
        (define (make-symbol symbol) (list 'symbol symbol #x123))
        (lambda (method . args)
            ((cons (cdr (assq method (list
                (cons 'intern (lambda (symbol)
                    (let ((entry (assq symbol table)))
                        (if (eq? #f entry)
                            (begin
                                (set! entry (cons symbol (make-symbol symbol)))
                                (set! table (cons entry table))))
                        (display table) (newline)
                        (cdr entry))))
                (cons 'bla (lambda () ...))
                (cons 'bli (lambda () ...))
                (cons 'blu (lambda () ...))
            ))) args)))))
(define test-memory
    (let ()
        (lambda (method . args)
            ((cons (cdr (assq method (list
                (cons 'intern (lambda ()
                    (let ((ret1 (memory 'intern 'testsymbol))
                          (ret2 (memory 'intern 'testsymbol)))
                        (display ret1) (newline)
                        (display ret2) (newline)
                        (display (eq? ret1 ret2)) (newline))
                ))
            ))) args)))))
(test-memory 'intern)

