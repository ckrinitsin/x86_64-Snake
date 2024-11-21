section .data

    ; position of the fruit
    global fruit_x
    global fruit_y
    fruit_x db 0
    fruit_y db 0

section .text
    global draw_fruit
    global spawn_fruit
    extern width
    extern height
    extern reset_cursor
    extern write_byte
    extern move_cursor_right
    extern move_cursor_down

spawn_fruit:

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
