'(load "/opt/local/lib/gambit-c/syntax-case.scm")
(define (integer->hex n) (number->string n 16))
(define out-pos 0)
(define (emit-byte n)
  (cond ((> n 255) '(error out-of-range))
        ((< n 0) '(error out-of-range))
        (else (if (< n 16) (display "0"))
              (display (integer->hex n))
              (display " ")
              (set! out-pos (+ out-pos 1)) )))
(define (emit-bytes list-of-bytes)
  (map emit-byte list-of-bytes))
(define (word->bytes n)
  (let ((hi (quotient n 256))
        (lo (remainder n 256)))
    (list lo hi)))
(define (dword->bytes n)
  (let* ((hi (quotient n 16777216))
         (hirest (remainder n 16777216))
         (lo (quotient hirest 65536))
         (lorest (remainder hirest 65536)))
    (append (word->bytes lorest) (list lo hi))))
(define (emit-word n)
  (emit-bytes (word->bytes n)))
(define (emit-dword n)
  (emit-bytes (dword->bytes n)))
(define (org pos) (set! out-pos pos))
(define (until pos data)
  (cond ((> pos out-pos)
          (emit-byte data)
          (until pos data))
        ((< pos out-pos)
          '(error "pos is smaller than current pos"))
        (else #t) ))
(define (assemble opcode . args)
  (define registers '(al cl dl bl ah ch dh bh ax cx dx bx sp bp si di eax ecx edx ebx esp ebp esi edi))
  (define (get-register-cardinality reg)
    (define (loop regs count)
      (if (eq? (car regs) 'eax) (set! count (- count 8)))
      (cond ((eq? reg (car regs)) count)
            (else (loop (cdr regs) (+ count 1)))))
    (loop registers 0))
  (define control-registers '(cr0 cr2 cr3))
  (define (register? r) (memq r registers))
  (define (control-register? r) (memq r control-registers))
  (define immediate? number?)
  (define (get-argument-type arg)
    (cond ((immediate? arg) 'immediate)
          ((address? arg) 'address)
          ((register? arg) arg)))
  (define ops (list
    (cons 'mov (lambda (args)
      (cond ((and (register? (car args))
                  (control-register? (cadr args)))
             (emit-byte #x0f)
             (emit-byte #x20)
             (emit-byte #xc0))
            ((and (control-register? (car args))
                  (register? (cadr args)))
             (emit-byte #x0f)
             (emit-byte #x22)
             (emit-byte #xc0))
            ((and (register? (car args))
                  (immediate? (cadr args)))
             (emit-byte (+ #xb0 (get-register-cardinality (car args))))
             (cond ((< (get-register-cardinality (car args)) 8) (emit-byte (cadr args)))
                   ((< (cadr args) 65536) (emit-word (cadr args)))
                   (else (emit-dword (cadr args)))))
            (else
              (display 'todo)))))
    (cons 'pusha (lambda (args)
      (emit-byte #x60)))
    (cons 'popa (lambda (args)
      (emit-byte #x61)))
    (cons 'int (lambda (args)
      (emit-byte #xcd)
      (emit-byte (car args))))
    (cons 'ret (lambda (args)
      (emit-byte #xc3)))
    (cons 'or (lambda (args)
      (cond ((and (register? (car args))
                  (immediate? (cadr args)))
             (emit-byte #x66)
             (emit-byte #x0d)
             (emit-dword (cadr args)))
            (else
              (display 'todo)))))))
  (if (assq opcode ops)
    (begin
      ((cdr (assq opcode ops)) args))))
(define-syntax asm
  (syntax-rules ()
                ((_ (opcode . args) ...)
                 (begin (apply assemble (cons (quote opcode) (quote args))) ...) )))
(define (protected-mode)
  (asm
    (mov eax cr0)                                              '(0f 20 c0)
    (or eax 1)                                                 '(66 0d 01 00 00 00)
    (mov cr0 eax)))                                            '(0f 22 c0)
(define (clear-screen)
  (asm
    (pusha)                                                    '(60)
    (mov ax #x600)            '("Scroll up window")            '(b8 00 60)
    (mov cx 0)                '("Upper left corner")           '(b9 00 00)
    (mov dx #x184f)           '("Lower right corner")          '(ba 4f 18)
    (mov bh 7)                '("Normal attributes")           '(b7 07)
    (int #x10)                                                 '(cd 10)
    (mov ah 2)                '("Locate cursor at 0,0")        '(b4 02)
    (mov bh 0)                '("Video page 0")                '(b7 00)
    (mov dx 0)                '("Row 0, Col 0")                '(ba 00 00)
    (int #x10)                                                 '(cd 10)
    (popa)                                                     '(61) '(c3)
    (ret)))
(define (make-mbr)
  (org #x7bb400)
  (until (+ #x7bb400 #x1b8) 64)
  (until (+ #x7bb400 #x1bc) 65)
  (until (+ #x7bb400 #x1be) 0)
  (until (+ #x7bb400 #x1fe) 255) '(partition table)
  (emit-byte #x55) (emit-byte #xaa) '(MBR signature))
(clear-screen)
(newline)
