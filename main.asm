section .data

    ; cursor management
    reset_cursor db 0x1B , '[H', 0
    reset_cursor_len equ $ - reset_cursor
    up_cursor db 0x1B , '[A', 0
    up_cursor_len equ $ - up_cursor
    bottom_cursor db 0x1B , '[B', 0
    bottom_cursor_len equ $ - bottom_cursor
    right_cursor db 0x1B , '[C', 0
    right_cursor_len equ $ - right_cursor
    left_cursor db 0x1B , '[D', 0
    left_cursor_len equ $ - left_cursor

    ; example messages for later
    message1 db "Hello, World!", 0xA
    msg_len1 equ $ - message1          
    message2 db "Hello 2!", 0xA  
    msg_len2 equ $ - message2
    
    ; array of snake - 1000 thousand bytes means max length is 500
    ; head is at snake[0]
    snake TIMES 1000 db 0

    ; direction of the snake:
    ;   3
    ; 2 x 0
    ;   1
    direction db 0

section .bss
    buffer resb 1

section .rodata
    ; width and height of the playable area
    ; (without the borders)
    global width
    global height
    width db 70
    height db 30

section .text
    extern draw_border
    extern write_byte
    extern clear_screen
    global _start 

draw_snake:
    push rbx
    mov bh, byte [snake]
    mov bl, byte [snake+1]
_10:

    pop rbx
    ret

_start:
    call clear_screen
    call draw_border

    mov byte [snake], 5
    mov byte [snake+1], 5

    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, reset_cursor                
    mov rdx, reset_cursor_len                
    syscall                         
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, bottom_cursor                
    mov rdx, bottom_cursor_len                
    syscall                         
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, right_cursor                
    mov rdx, right_cursor_len                
    syscall                         

    mov rax, 0           ; Syscall for read
    mov rdi, 0           ; stdin
    mov rsi, buffer      ; Address of the buffer
    mov rdx, 1           ; Read 1 byte
    syscall

    ; If a key was pressed, store it in `input`
    test rax, rax        ; Check if any input was received
    jz exit         ; If no input, skip
    mov al, byte [buffer]; Load the input character

    ;mov rax, 'x'
    call write_byte

exit: ; exit syscall with return code 0
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
