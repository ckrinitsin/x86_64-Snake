section .data
    ; messages
    game_over_message db "gameover", 0xA, "space - retry", 0xA, "q - quit", 0xA
    game_over_message_len equ $ - game_over_message
    pause_message db "pause", 0xA, "esc - unpause", 0xA, "q - quit", 0xA
    pause_message_len equ $ - pause_message
    start_message db "snake", 0xA, "space - start", 0xA, "q - quit", 0xA
    start_message_len equ $ - start_message

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

    ; termios struct for ioctl
    termios dd 0            ; c_iflag
            dd 0            ; c_oflag
            dd 0            ; c_cflag
    c_lflag dd 0            ; c_lflag
            db 0            ; c_lin
    c_cc    times 19 db 0   ; c_cc

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
    global write_game_over_message
    global write_pause_message
    global write_start_message
    global set_terminal_options
    global restore_terminal_options
    extern height

set_terminal_options:
    ; get current termios struct
    mov rax, 0x10   ; ioctl
    mov rdi, 0      ; stdin
    mov rsi, 0x5401 ; TCGETS
    lea rdx, [termios]
    syscall

    ; unset ECHO and ICANON flags
    mov ebx, [c_lflag]
    and ebx, 0xFFFFFFF5 ; ~(ICANON | ECHO)
    xchg ebx, [c_lflag] ; exchange to store previous value

    ; set MIN control character to 0 and store previous value
    mov r12b, 0
    xchg r12b, [c_cc + 6]

    ; set the updated values
    mov rax, 0x10   ; ioctl
    mov rdi, 0      ; stdin
    mov rsi, 0x5402 ; TCSETS
    lea rdx, [termios]
    syscall

    ; write old values to memory to later restore the previous settings
    mov [c_lflag], ebx
    mov [c_cc + 6], r12b

    ret

restore_terminal_options:
    ; restore the previously saved termios
    mov rax, 0x10   ; ioctl
    mov rdi, 0      ; stdin
    mov rsi, 0x5402 ; TCSETS
    lea rdx, [termios]
    syscall

    ret

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

cursor_to_message_position:
    push rbx
    call reset_cursor
    mov bl, byte [height] 

_loop_message:
    call move_cursor_down
    dec bl
    cmp bl, -2
    jne _loop_message
    
    pop rbx
    ret

write_game_over_message:
    push rdi

    call cursor_to_message_position

    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, game_over_message                
    mov rdx, game_over_message_len                
    syscall                         

    pop rdi
    ret

write_pause_message:
    push rdi

    call cursor_to_message_position

    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, pause_message                
    mov rdx, pause_message_len                
    syscall                         

    pop rdi
    ret

write_start_message:
    push rdi

    call cursor_to_message_position

    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, start_message                
    mov rdx, start_message_len                
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

