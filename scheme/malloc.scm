(define malloctest
  (let ((max-mem (* 1024 1024))
        (mem-used 0)
        (bytes-wasted 0)
        (re-usings 0)
        (the-list '())
        (allocations 0)
        (freeings 0)
        (randoms '(
          40 100 101 102 105 110 101 32 109 97 108 108 111 99 116 101
          115 116 10 32 32 40 108 101 116 32 40 40 109 97 120 45
          109 101 109 32 40 42 32 49 48 50 52 32 49 48 50 52
          41 41 10 32 32 32 32 32 32 32 32 40 109 101 109 45
          117 115 101 100 32 48 41 10 32 32 32 32 32 32 32 32
          40 116 104 101 45 108 105 115 116 32 39 40 41 41 41 10
          32 32 32 32 40 100 101 102 105 110 101 32 40 100 117 109
          112 41 10 32 32 32 32 32 32 40 100 105 115 112 108 97
          121 32 116 104 101 45 108 105 115 116 41 41 10 32 32 32
          32 40 100 101 102 105 110 101 32 40 109 97 107 101 45 99
          104 117 110 107 32 98 121 116 101 115 41 10 32 32 32 32
          32 32 40 108 105 115 116 32 39 99 104 117 110 107 32 39
          117 115 101 100 32 98 121 116 101 115 41 41 10 32 32 32
          32 40 100 101 102 105 110 101 32 40 103 101 116 45 99 104
          117 110 107 45 115 105 122 101 32 99 104 117 110 107 41 10
          32 32 32 32 32 32 40 99 97 100 100 114 32 99 104 117
          110 107 41 41 10 32 32 32 32 40 100 101 102 105 110 101
          32 40 99 104 117 110 107 45 117 115 101 100 63 32 99 104
          117 110 107 41 10 32 32 32 32 32 32 40 61 32 39 117
          115 101 100 32 40 99 97 100 114 32 99 104 117 110 107 41
          41 41 10 32 32 32 32 40 100 101 102 105 110 101 32 40
          99 104 117 110 107 45 117 115 101 100 33 32 99 104 117 110
          107 41 10 32 32 32 32 32 32 40 115 101 116 45 99 97
          114 33 32 39 117 115 101 100 32 40 99 100 114 32 99 104
          117 110 107 41 41 10 32 32 32 32 32 32 99 104 117 110
          107 41 10 32 32 32 32 40 100 101 102 105 110 101 32 40
          99 104 117 110 107 45 102 114 101 101 33 32 99 104 117 110
          107 41 10 32 32 32 32 32 32 40 115 101 116 45 99 97
          114 33 32 39 102 114 101 101 32 40 99 100 114 32 99 104
          117 110 107 41 41 10 32 32 32 32 32 32 99 104 117 110
          107 41 10 32 32 32 32 40 100 101 102 105 110 101 32 40
          102 105 110 100 45 102 114 101 101 45 99 104 117 110 107 32
          98 121 116 101 115 32 108 115 116 41 10 32 32 32 32 32
          32 40 105 102 32 40 110 117 108 108 63 32 108 115 116 41
          10 32 32 32 32 32 32 32 32 39 40 41 10 32 32 32
          32 32 32 32 32 40 105 102 32 40 97 110 100 32 40 99
          104 117 110 107 45 102 114 101 101 63 32 40 99 97 114 32
          108 115 116 41 41 10 32 32 32 32 32 32 32 32 32 32
          32 32 32 32 32 32 32 40 62 61 32 40 103 101 116 45
          99 104 117 110 107 45 115 105 122 101 32 40 99 97 114 32
          108 115 116 41 41 32 98 121 116 101 115 41 10 32 32 32
          32 32 32 32 32 32 32 40 99 97 114 32 108 115 116 41
          10 32 32 32 32 32 32 32 32 32 32 40 102 105 110 100
          45 102 114 101 101 45 99 104 117 110 107 32 98 121 116 101
          115 32 40 99 100 114 32 108 115 116 41 41 41 41 41 10
          32 32 32 32 40 100 101 102 105 110 101 32 40 109 97 108
          108 111 99 32 98 121 116 101 115 41 10 32 32 32 32 32
          32 40 111 114 32 40 102 105 110 100 45 102 114 101 101 45
          99 104 117 110 107 32 98 121 116 101 115 32 116 104 101 45
          108 105 115 116 41 10 32 32 32 32 32 32 32 32 32 32
          40 105 102 32 40 60 61 32 98 121 116 101 115 32 40 45
          32 109 97 120 45 109 101 109 32 109 101 109 45 117 115 101
          100 41 41 10 32 32 32 32 32 32 32 32 32 32 32 32
          40 108 101 116 32 40 40 110 101 119 45 99 104 117 110 107
          32 40 109 97 107 101 45 99 104 117 110 107 32 98 121 116
          101 115 41 41 41 10 32 32 32 32 32 32 32 32 32 32
          32 32 32 32 40 115 101 116 33 32 116 104 101 45 108 105
          115 116 32 40 99 111 110 115 32 40 99 111 110 115 32 109
          101 109 45 117 115 101 100 32 110 101 119 45 99 104 117 110
          107 41 32 116 104 101 45 108 105 115 116 41 41 10 32 32
          32 32 32 32 32 32 32 32 32 32 32 32 40 115 101 116
          33 32 109 101 109 45 117 115 101 100 32 40 43 32 109 101
          109 45 117 115 101 100 32 98 121 116 101 115 41 41 10 32
          32 32 32 32 32 32 32 32 32 32 32 32 32 110 101 119
          45 99 104 117 110 107 41 10 32 32 32 32 32 32 32 32
          32 32 32 32 39 40 41 41 41 41 10 32 32 32 32 40
          100 101 102 105 110 101 32 40 102 114 101 101 32 97 100 100
          114 41 10 32 32 32 32 32 32 40 100 101 102 105 110 101
          32 40 100 101 108 101 116 101 32 105 116 101 109 32 108 115
          116 41 10 32 32 32 32 32 32 32 32 40 105 102 32 40
          101 113 63 32 105 116 101 109 32 40 99 97 114 32 108 115
          116 41 41 10 32 32 32 32 32 32 32 32 32 32 40 99
          100 114 32 108 115 116 41 10 32 32 32 32 32 32 32 32
          32 32 40 99 111 110 115 32 40 99 97 114 32 108 115 116
          41 32 40 100 101 108 101 116 101 32 105 116 101 109 32 40
          99 100 114 32 108 115 116 41 41 41 41 41 10 32 32 32
          32 32 32 40 99 104 117 110 107 45 102 114 101 101 33 32
          40 99 100 114 32 40 97 115 115 113 32 97 100 100 114 32
          116 104 101 45 108 105 115 116 41 41 41 41 10 10 32 32
          32 32 40 108 97 109 98 100 97 32 40 41 10)))
    (define (dump)
      '(display the-list) '(newline))
    (define (make-chunk bytes)
      (list 'chunk 'used bytes bytes))
    (define (get-chunk-size chunk)
      (caddr chunk))
    (define (get-chunk-requested-bytes chunk)
      (cadddr chunk))
    (define (set-chunk-requested-bytes! chunk bytes)
      (set-car! (cdddr chunk) bytes)
      chunk)
    (define (chunk-free? chunk)
      (eq? 'free (cadr chunk)))
    (define (chunk-used? chunk)
      (eq? 'used (cadr chunk)))
    (define (chunk-used! chunk)
      (set-car! (cdr chunk) 'used)
      chunk)
    (define (chunk-free! chunk)
      (set-car! (cdr chunk) 'free)
      chunk)
    (define (find-free-chunk bytes lst)
      (if (null? lst)
        #f
        (let ((chunk (cdar lst)))
          (if (chunk-free? chunk)
            '(begin
              (display "Chunk is free: ")
              (display chunk)
              (if (>= (get-chunk-size chunk) bytes)
                (display "Chunk is large enough: "))
              (newline) ))
          (if (and (chunk-free? chunk)
                   (>= (get-chunk-size chunk) bytes))
            (begin
              (display "Re-using chunk ") (display chunk) (display " for ") (display bytes) (newline)
              (set! bytes-wasted
                (+ bytes-wasted
                   (- (get-chunk-size chunk) bytes) ))
              (set! re-usings (+ re-usings 1))
              (set-chunk-requested-bytes! (chunk-used! chunk) bytes) )
            (find-free-chunk bytes (cdr lst)) ))))
    (define (malloc bytes)
      (set! allocations (+ allocations 1))
      (or (find-free-chunk bytes the-list)
          (if (<= bytes (- max-mem mem-used))
            (let ((new-chunk (make-chunk bytes)))
              (display "Adding new chunk.") (newline)
              (set! the-list (cons (cons mem-used new-chunk) the-list))
              (set! mem-used (+ mem-used bytes))
              new-chunk)
            '())))
    (define (free addr)
      (let ((chunk (cdr (assq addr the-list))))
        (if (chunk-free? chunk)
          #f
          (begin
            (display "Freeing chunk ") (display chunk) (newline)
            (set! freeings (+ freeings 1))
            (let ((wasted (- (get-chunk-size chunk) (get-chunk-requested-bytes chunk))))
              (set! bytes-wasted (- bytes-wasted wasted))
              (set-chunk-requested-bytes! chunk (get-chunk-size chunk))
              (chunk-free! chunk) )))))
    (lambda ()
      (define (element-at lst idx)
        (if (= 1 idx)
          (car lst)
          (element-at (cdr lst) (- idx 1))))
      (define (loop lst)
        (dump)
        (if (null? lst)
          'end
          (begin
            (if (<= 100 (car lst))
              (malloc (car lst))
              (if (null? the-list)
                (malloc (car lst))
                (free (car (element-at the-list (+ 1 (remainder (car lst) (length the-list)))))) ))
            (loop (cdr lst)))))
      (loop randoms)
      (newline) (newline)
      (display "Allocations: ") (display allocations) (newline)
      (display "Freeings: ") (display freeings) (newline)
      (display "mem-used: ") (display mem-used) (newline)
      (display "bytes-wasted: ") (display bytes-wasted) (newline)
      (display "re-usings: ") (display re-usings) (newline)
      )))
(malloctest)
