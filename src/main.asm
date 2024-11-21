section .data

    ; example messages for later
    message1 db "Hello, World!", 0xA
    msg_len1 equ $ - message1          
    message2 db "Hello 2!", 0xA  
    msg_len2 equ $ - message2
    
    ; array of snake - 1000 thousand bytes means max length is 500
    ; x head is at snake[0]
    ; y head is at snake[1]
    snake TIMES 250 db 0
    snake_length db 2

    ; direction of the snake:
    ;   3
    ; 2 x 0
    ;   1
    global direction
    direction db 0

    ; delay of the game loop (0.5s in the beginning)
    timespec dq 0 
             dq 500000000

section .rodata
    ; width and height of the playable area
    ; (without the borders)
    global width
    global height
    width db 25
    height db 10

section .text
    extern fruit_x
    extern fruit_y
    extern spawn_fruit
    extern draw_fruit
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
    ;;push r12
    xor rdx, rdx

    push rdx
    call reset_cursor
    pop rdx

_12:
    mov bh, byte [snake+(2*rdx)]
    mov bl, byte [snake+(2*rdx)+1]

_10:push rdx
    call move_cursor_right
    pop rdx
    dec bh
    cmp bh, 0
    jnz _10
_11:push rdx
    call move_cursor_down
    pop rdx
    dec bl
    cmp bl, 0
    jnz _11

    push rdx
    mov rax, 'x'
    call write_byte
    call reset_cursor
    pop rdx

    inc rdx
    cmp dl, byte [snake_length]
    jnz _12

    ;;pop r12
    pop rbx
    ret

move_snake:
    ;; TODO: loop this
    mov ah, byte [snake]
    mov al, byte [snake+1]
    mov byte [snake+2], ah
    mov byte [snake+3], al
    ;;

    cmp byte [direction], 0
    je _move_right
    cmp byte [direction], 1
    je _move_down
    cmp byte [direction], 2
    je _move_left
    cmp byte [direction], 3
    je _move_up
    ret ; should not be accessed

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

check_eat_fruit:
    mov ah, byte [fruit_x]
    mov al, byte [fruit_y]
    cmp byte [snake], ah 
    jz _check_y
    ret
_check_y:
    cmp byte [snake+1], al
    jz _same_position
    ret
_same_position:
    ; get longer
    inc byte [snake_length]
    call spawn_fruit
    ret

_start:
    call hide_cursor
    mov byte [snake], 5
    mov byte [snake+1], 5
    mov byte [snake+2], 4
    mov byte [snake+3], 5
    call spawn_fruit 

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
    call check_eat_fruit

    jmp main_loop

exit: ; exit syscall with return code 0
    call show_cursor
    call clear_screen
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
