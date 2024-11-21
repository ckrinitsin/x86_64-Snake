section .text
    extern height
    extern width
    extern write_byte
    global draw_border

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

    mov rax, 10 ;newline
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
