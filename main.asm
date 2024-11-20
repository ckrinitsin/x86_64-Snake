section .data

    ; example messages for later
    message1 db "Hello, World!", 0xA
    msg_len1 equ $ - message1          
    message2 db "Hello 2!", 0xA  
    msg_len2 equ $ - message2
    
    ; array of snake - 1000 thousand bytes means max length is 500
    ; x head is at snake[0]
    ; y head is at snake[1]
    snake TIMES 1000 db 0

    ; direction of the snake:
    ;   3
    ; 2 x 0
    ;   1
    direction db 0

    timespec dq 0 
             dq 500000000

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
    extern reset_cursor
    extern move_cursor_right
    extern move_cursor_down
    global _start 

draw_snake:
    push rbx
    call reset_cursor
    mov bh, byte [snake]
    mov bl, byte [snake+1]

_10:call move_cursor_right
    dec bh
    cmp bh, 0
    jnz _10
_11:call move_cursor_down
    dec bl
    cmp bl, 0
    jnz _11

    mov rax, 'x'
    call write_byte

    pop rbx
    call reset_cursor
    ret

_start:
    mov byte [snake], 5
    mov byte [snake+1], 5

main_loop:
    call clear_screen
    call draw_border
    call draw_snake

    lea rdi, [timespec]    ; Pointer to timespec struct (rdi)
    xor rsi, rsi           ; NULL (no remaining time)
    mov rax, 35            ; Syscall number for nanosleep
    syscall

    inc byte [snake]

    jmp main_loop

;    mov rax, 0           ; Syscall for read
;    mov rdi, 0           ; stdin
;    mov rsi, buffer      ; Address of the buffer
;    mov rdx, 1           ; Read 1 byte
;    syscall

    ; If a key was pressed, store it in `input`
;    test rax, rax        ; Check if any input was received
;    jz exit         ; If no input, skip


;    mov al, byte [buffer]; Load the input character
    ;mov rax, 'x'
;    call write_byte

exit: ; exit syscall with return code 0
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
