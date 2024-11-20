section .data
    ; escape code for clearing the screen
    clear db 0x1B, '[2J', 0x1B, '[H', 0
    clear_len equ $ - clear 

section .bss
    ; adress for syscall for write_byte wrapper
    byte_to_write resb 1

section .text
    global write_byte
    global clear_screen

write_byte:
    push rdi

    mov byte [byte_to_write], al
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, byte_to_write                
    mov rdx, 1                
    syscall                         

    pop rdi
    ret

clear_screen:
    push rdi

    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, clear                
    mov rdx, clear_len                
    syscall                         

    pop rdi
    ret

