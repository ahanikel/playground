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
  (define eax 'eax)
  (define cr0 'cr0)
  (define get-first-arg car)
  (define get-second-arg cadr)
  (define (register? r) (assq r '((eax . eax))))
  (define (control-register? r) (assq r '((cr0 . cr0))))
  (define immediate? number?)
  (define (get-argument-type arg)
    (cond ((immediate? arg) 'immediate)
	  ((address? arg) 'address)
	  ((register? arg) arg)))
  (define ops (list
    (cons 'mov (lambda (args)
      (define get-dest get-first-arg)
      (define get-src get-second-arg)
      (cond ((and (register? (get-dest args))
  		(control-register? (get-src args)))
  	   (emit-byte #x0f)
  	   (emit-byte #x20)
  	   (emit-byte #xc0))
  	  ((and (control-register? (get-dest args))
  		(register? (get-src args)))
  	   (emit-byte #x0f)
  	   (emit-byte #x22)
  	   (emit-byte #xc0))
  	  (else
  	    (display 'todo)))))
    (cons 'pusha (lambda ()
      (emit-byte #x60)))
    (cons 'popa (lambda ()
      (emit-byte #x61)))
    (cons 'int (lambda ()
      (emit-byte #xcd)
      (emit-byte (get-first-arg args))))
    (cons 'or (lambda (args)
      (cond ((and (register? (get-dest args))
  		(immediate? (get-src args)))
  	   (emit-byte #x66)
  	   (emit-byte #x0d)
  	   (emit-dword (get-src args)))
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
    (mov eax cr0) 	'(0f 20 c0)
    (or eax 1)		'(66 0d 01 00 00 00)
    (mov cr0 eax)))	'(0f 22 c0)
(define (clear-screen)
  (asm
    (pusha)							'(60)
    (mov ax #x600)		'("Scroll up window")		'(b8 00 60)
    (mov cx 0)			'("Upper left corner")		'(b9 00 00)
    (mov dx #x184f)		'("Lower right corner")		'(ba 4f 18)
    (mov bh 7)			'("Normal attributes")		'(b7 07)
    (int #x10)							'(cd 10)
    (mov ah 2)			'("Locate cursor at 0,0")	'(b4 02)
    (mov bh 0)			'("Video page 0")		'(b7 00)
    (mov dx 0)			'("Row 0, Col 0")		'(ba 00 00)
    (int #x10)							'(cd 10)
    (popa)							'(61) '(c3)
    (ret)))
(define (make-mbr)
  (org #x7bb400)
  (protected-mode)
  (until (+ #x7bb400 #x1b8) 64)
  (until (+ #x7bb400 #x1bc) 65)
  (until (+ #x7bb400 #x1be) 0)
  (until (+ #x7bb400 #x1fe) 255) '(partition table)
  (emit-byte #x55) (emit-byte #xaa) '(MBR signature))
(protected-mode)
(newline)
