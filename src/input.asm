section .bss
    input_buffer resb 250

section .text
    global input
    global read_input
    global start_screen
    extern direction
    extern exit
    extern timespec
    extern write_pause_message
    extern write_start_message

input:
    call read_input
    call handle_input
    ret

handle_input:
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
    je _pause
    ret
_pause:
    mov byte [input_buffer], 'w'
    call pause
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
    mov al, byte [input_buffer]
    ret

pause:
    call write_pause_message
    mov rax, 35            
    lea rdi, [timespec]   
    xor rsi, rsi           
    syscall

    call read_input
    cmp al, 'q'
    je exit
    cmp al, 27 ; esc
    jne pause
    mov byte [input_buffer], '0'
    ret

start_screen:
    call write_start_message
    mov rax, 35            
    lea rdi, [timespec]   
    xor rsi, rsi           
    syscall

    call read_input
    cmp al, 'q'
    je exit
    cmp al, 32 ; space
    jne start_screen
    mov byte [input_buffer], '0'
    ret
