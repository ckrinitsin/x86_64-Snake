section .data

    ; array of snake - 500 bytes means max length is 250
    ; x of i-th part is at snake[2*i]
    ; y of i-th part is at snake[2*i+1]
    snake times 500 db 0
    snake_length db 3

    ; direction of the snake:
    ;   3
    ; 2 x 0
    ;   1
    global direction
    direction db 0

    ; delay of the game loop (0.25s in the beginning)
    global timespec
    timespec dq 0 
             dq 250000000

section .rodata
    ; width and height of the playable area
    ; (without the borders)
    global width
    global height
    width db 25
    height db 10

section .text
    extern write_game_over_message
    extern start_screen
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
    extern read_input
    global _start 
    global exit

spawn_tail:
    inc byte [snake_length]
    xor rdx, rdx
    mov dl, byte [snake_length]
    mov ch, byte [snake+(2*rdx)-4]
    mov cl, byte [snake+(2*rdx)-3]
    mov byte [snake+(2*rdx)-2], ch
    mov byte [snake+(2*rdx)-1], cl

    mov ah, byte [direction]
    cmp ah, 0
    jz _spawn_left
    cmp ah, 2
    jz _spawn_right
    cmp ah, 3
    jz _spawn_down
    cmp ah, 1
    jz _spawn_up
    ret ; should not reach this line

_spawn_right:
    inc byte [snake+(2*rdx)-2]
    ret
_spawn_down:
    inc byte [snake+(2*rdx)-1]
    ret
_spawn_left:
    dec byte [snake+(2*rdx)-2]
    ret
_spawn_up:
    dec byte [snake+(2*rdx)-1]
    ret

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
    mov rax, 'X'
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
    xor rdx, rdx
    mov dl, byte [snake_length]
_move_body:
    cmp dl, 1
    jz _move_head

    mov ah, byte [snake+(2*rdx)-4]
    mov al, byte [snake+(2*rdx)-3]
    mov byte [snake+(2*rdx)-2], ah
    mov byte [snake+(2*rdx)-1], al

    dec dl
    jmp _move_body

_move_head:
    mov ah, byte [width]
    mov al, byte [height]
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
    cmp byte [snake], ah
    jz _to_left_border
    inc byte [snake]
    ret
_move_down:
    cmp byte [snake+1], al
    jz _to_top_border
    inc byte [snake+1]
    ret
_move_left:
    cmp byte [snake], 1
    jz _to_right_border
    dec byte [snake]
    ret
_move_up:
    cmp byte [snake+1], 1
    jz _to_bottom_border
    dec byte [snake+1]
    ret

_to_left_border:
    mov byte [snake], 1
    ret

_to_right_border:
    mov al, byte [width]
    mov byte [snake], al
    ret

_to_top_border:
    mov byte [snake+1], 1
    ret

_to_bottom_border:
    mov al, byte [height]
    mov byte [snake+1], al
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
    call spawn_tail
    call spawn_fruit
    ret

check_loose:
    xor rcx, rcx
    mov cl, byte [snake_length]
    mov ah, byte [snake]
    mov al, byte [snake+1]
_loop_through_snake:
    cmp rcx, 4 
    jle _loop_return

    mov dh, byte [snake+(2*rcx)-2]
    mov dl, byte [snake+(2*rcx)-1]

    dec rcx

    cmp ah, dh
    jnz _loop_through_snake
    cmp al, dl
    jnz _loop_through_snake
    jmp game_over

_loop_return:    
    ret

_start:
    call clear_screen
    call draw_border
    call hide_cursor
    call start_screen

_start_game:
    ; set starting positions
    mov byte [snake], 5
    mov byte [snake+1], 5
    mov byte [snake+2], 4
    mov byte [snake+3], 5
    mov byte [snake+4], 3
    mov byte [snake+5], 5
    mov byte [snake_length], 3
    mov byte [direction], 0
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
    call check_loose
    call check_eat_fruit

    jmp main_loop

game_over:
    call write_game_over_message
    mov rax, 35            
    lea rdi, [timespec]   
    xor rsi, rsi           
    syscall

    call read_input ; writes input byte into al
    cmp al, 32 ; space
    je _start_game
    cmp al, 'q' ; escape
    je exit
    jmp game_over

exit: ; exit syscall with return code 0
    call show_cursor
    call clear_screen
    mov rax, 60                     
    xor rdi, rdi                    
    syscall                         
