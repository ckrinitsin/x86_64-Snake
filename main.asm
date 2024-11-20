section .data
    clear db 0x1B, '[2J', 0x1B, '[H', 0
    clear_len equ $ - clear 
    message1 db "Hello, World!", 0xA
    msg_len1 equ $ - message1          
    message2 db "Hello 2!", 0xA  
    msg_len2 equ $ - message2

section .rodata
    width db 70
    height db 30

section .bss
    byte_to_write resb 1

section .text
    global _start 

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

draw_upper_lower_line:
    push rbx
    mov rax, '+'
    call write_byte
    mov bl, byte [width]
_01:mov rax, '-'
    call write_byte
    dec bl
    cmp bl, 0
    jnz _01
    mov rax, '+'
    call write_byte
    mov rax, 10 ;newline
    call write_byte
    pop rbx
    ret

draw_left_right_lines:
    push rbx
    mov rax, '|'
    call write_byte
    mov bl, byte [width]
_02:mov rax, 32 ;space
    call write_byte
    dec bl
    cmp bl, 0
    jnz _02
    mov rax, '|'
    call write_byte
    mov rax, 10;newline
    call write_byte
    pop rbx
    ret

draw_border:
    push rbx

    call draw_upper_lower_line
    mov bl, byte [height]
_03:call draw_left_right_lines
    dec bl
    cmp bl, 0
    jnz _03

    call draw_upper_lower_line

    pop rbx
    ret


_start:
    call clear_screen
    call draw_border


exit:
    ; exit syscall with return code 0
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
