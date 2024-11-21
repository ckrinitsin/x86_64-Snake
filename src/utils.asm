section .data
    ; escape code for clearing the screen
    clear db 0x1B, '[2J', 0x1B, '[H', 0
    clear_len equ $ - clear 

    ; cursor management
    reset_cursor_code db 0x1B , '[H', 0
    reset_cursor_len equ $ - reset_cursor_code
    bottom_cursor db 0x1B , '[B', 0
    bottom_cursor_len equ $ - bottom_cursor
    right_cursor db 0x1B , '[C', 0
    right_cursor_len equ $ - right_cursor

    hide_cursor_code db 0x1B, '[', '?', '2', '5', 'l', 0  ; Escape sequence to hide the cursor
    show_cursor_code db 0x1B, '[', '?', '2', '5', 'h', 0  ; Escape sequence to show the cursor

section .bss
    ; adress for syscall for write_byte wrapper
    byte_to_write resb 1

section .text
    global write_byte
    global clear_screen
    global move_cursor_right
    global move_cursor_down
    global reset_cursor
    global hide_cursor
    global show_cursor

hide_cursor:
    push rdi
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, hide_cursor_code 
    mov rdx, 6                
    syscall                         

    pop rdi
    ret

show_cursor:
    push rdi
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, show_cursor_code 
    mov rdx, 6                
    syscall                         

    pop rdi
    ret

reset_cursor:
    push rdi
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, reset_cursor_code 
    mov rdx, reset_cursor_len                
    syscall                         

    pop rdi
    ret

move_cursor_right:
    push rdi

    mov rax, 1
    mov rdi, 1
    mov rsi, right_cursor
    mov rdx, right_cursor_len
    syscall

    pop rdi
    ret

move_cursor_down:
    push rdi

    mov rax, 1
    mov rdi, 1
    mov rsi, bottom_cursor
    mov rdx, bottom_cursor_len
    syscall

    pop rdi
    ret

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

