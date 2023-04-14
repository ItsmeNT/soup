global _start

section .data
    sleep_duration dd 1
    soup_msg db 'soup', 10
    soup_msg_len equ $-soup_msg

section .text
_start:
    ; Print "soup" every second
print_loop:
    ; Write "soup" to stdout
    mov eax, 4          ; sys_write
    mov ebx, 1          ; file descriptor (stdout)
    lea ecx, [soup_msg] ; address of the string
    mov edx, soup_msg_len ; length of the string
    int 0x80            ; call kernel

    ; Sleep for 1 second
    mov eax, 162        ; sys_nanosleep
    sub esp, 8          ; allocate space for timespec struct
    mov dword [esp], sleep_duration ; seconds
    mov dword [esp+4], 0            ; nanoseconds
    lea ebx, [esp]                  ; address of timespec struct
    int 0x80                        ; call kernel
    add esp, 8                      ; deallocate timespec struct

    jmp print_loop                 ; loop back to print soup again

; Exit cleanly when the user interrupts the program
section .bss
    exit_code resd 1

section .text
    ; Handle SIGINT (Ctrl+C)
signal_handler:
    mov dword [exit_code], 1
    ret

_start:
    ; Register signal handler for SIGINT
    mov eax, 48          ; sys_signal
    mov ebx, 2           ; SIGINT
    lea ecx, [signal_handler] ; address of the signal handler
    int 0x80             ; call kernel

print_loop:
    ; Check if exit_code is set
    cmp dword [exit_code], 0
    jne exit

    ; Print "soup" and sleep
    call print_soup
    call sleep_one_second
    jmp print_loop

; Print "soup" to stdout
print_soup:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; file descriptor (stdout)
    lea ecx, [soup_msg] ; address of the string
    mov edx, soup_msg_len ; length of the string
    int 0x80            ; call kernel
    ret

; Sleep for 1 second
sleep_one_second:
    mov eax, 162        ; sys_nanosleep
    sub esp, 8          ; allocate space for timespec struct
    mov dword [esp], sleep_duration ; seconds
    mov dword [esp+4], 0            ; nanoseconds
    lea ebx, [esp]                  ; address of timespec struct
    int 0x80                        ; call kernel
    add esp, 8                      ; deallocate timespec struct
    ret

; Exit the program
exit:
    mov eax, 1          ; sys_exit
    mov ebx, 0          ; exit code
    int 0x80
    
