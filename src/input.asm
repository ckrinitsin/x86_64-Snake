section .bss
    input_buffer resb 250

section .text
    global input
    extern direction
    extern exit

input:
    call read_input
    call handle_input
    ret

handle_input:
    mov al, byte [input_buffer]
    mov ah, byte [direction]
    cmp al, 'w'
    je _input_up
    cmp al, 's'
    je _input_down
    cmp al, 'a'
    je _input_left
    cmp al, 'd'
    je _input_right
    cmp al, 27 ; escape
    je exit
    ret

_input_up:
    cmp ah, 1
    jnz _set_up
    ret
_set_up:
    mov byte [direction], 3
    ret
_input_down:
    cmp ah, 3
    jnz _set_down
    ret
_set_down:
    mov byte [direction], 1
    ret
_input_left:
    cmp ah, 0
    jnz _set_left
    ret
_set_left:
    mov byte [direction], 2
    ret
_input_right:
    cmp ah, 2
    jnz _set_right
    ret
_set_right:
    mov byte [direction], 0
    ret

read_input:
    mov rax, 0           
    mov rdi, 0           
    mov rsi, input_buffer
    mov rdx, 250          
    syscall
    ret
