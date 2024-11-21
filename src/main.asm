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
    snake_length dw 1

    ; position of the fruit
    fruit_x db 0
    fruit_y db 0

    ; direction of the snake:
    ;   3
    ; 2 x 0
    ;   1
    global direction
    direction db 0

    timespec dq 0 
             dq 500000000

section .rodata
    ; width and height of the playable area
    ; (without the borders)
    global width
    global height
    width db 70
    height db 30

section .text
    extern input
    extern draw_border
    extern write_byte
    extern clear_screen
    extern reset_cursor
    extern move_cursor_right
    extern move_cursor_down
    extern hide_cursor
    extern show_cursor
    global _start 
    global exit

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

move_snake:
    cmp byte [direction], 0
    je _move_right
    cmp byte [direction], 1
    je _move_down
    cmp byte [direction], 2
    je _move_left
    cmp byte [direction], 3
    je _move_up
    ret

_move_right:
    inc byte [snake]
    ret
_move_down:
    inc byte [snake+1]
    ret
_move_left:
    dec byte [snake]
    ret
_move_up:
    dec byte [snake+1]
    ret

fruit_position:

    ; x position
    rdtsc
    shr ax, 5
    div byte [width]
    mov byte [fruit_x], ah
;; TODO
    rdtsc
    shr ax, 5
    div byte [height]
    mov byte [fruit_y], ah

    ret

draw_fruit:
    push rbx
    call reset_cursor
    mov bh, byte [fruit_x]
    mov bl, byte [fruit_y]

_30:call move_cursor_right
    dec bh
    cmp bh, 0
    jnz _30
_31:call move_cursor_down
    dec bl
    cmp bl, 0
    jnz _31

    mov rax, '*'
    call write_byte

    pop rbx
    call reset_cursor
    ret

_start:
    call hide_cursor
    mov byte [snake], 5
    mov byte [snake+1], 5
    call fruit_position

main_loop:
    call clear_screen
    call draw_border
    call draw_snake
    call draw_fruit

    mov rax, 35            
    lea rdi, [timespec]   
    xor rsi, rsi           
    syscall

    call input
    call move_snake

    jmp main_loop

exit: ; exit syscall with return code 0
    call show_cursor
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
