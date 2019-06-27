; This file provides the following useful functions for your program:
;    read_int - read a decimal number from stdin, return it in eax
;    print_int - take a dword value on the stack, convert to decimal and display on stdout
;    print_newline - print a newline character to stdout
;    exit - end the current program


; The BSS section is for uninitialized data
section .bss

; Here we allocate 16-byte uninitialized buffer
; The name "buffer" refers to the address of the beginning of this region
; and end_of_buffer is the address of the first byte after this region
buffer: resb 16
end_of_buffer:

section .text

read_int:
    mov eax,3
    mov ebx,0
    mov ecx,buffer
    mov edx,end_of_buffer - buffer
    int 80h

    cmp eax, -1
    je .badread
    mov ecx, eax
    xor ebx, ebx
    xor eax, eax

.read_int_loop:
    cmp ebx, ecx
    jae .done

    xor edx, edx
    mov dl, [buffer+ebx]
    cmp dl, ' '
    je .skipit
    cmp dl, 10
    je .skipit
    cmp dl, 13
    je .skipit
    cmp dl, '0'
    jb .badread
    cmp dl, '9'
    ja .badread
    sub dl, '0'

    push edx
    inc ebx
    mov edi, 10
    mul edi
    pop edx
    jo .badread
    add eax, edx
    jo .badread

    jmp .read_int_loop
.badread:
    xor eax,eax
.done:
    ret
.skipit:
    inc ebx
    jmp .read_int_loop

; This function prints to the console the decimal representation
; of its 32-bit parameter, which is passed on the stack. It has
; no return value. Callee cleanup.
print_int:
    push ebp
    mov ebp, esp

    mov ecx, end_of_buffer-1   ; We want to start from the end of the buffer
    mov eax, [ebp+8]           ; load our parameter
    mov byte [ecx], '0'        ; initially, set the buffer equal to the character 00
    cmp eax, 0
    jne .digit_loop
    jmp .exit_digit_loop1

.digit_loop:                   ; the main loop
    cmp eax, 0                 ; if our number is zero, exit the loop
    je .exit_digit_loop

    xor edx, edx               ; extent the 32-bit value into a 64-bit value
    mov ebx, 10                ; div doen't take immediates, so load divisor into register
    div ebx                    ; this divides edx:eax by ebx. Quotient is in eax, remainder is in edx
    add dl, '0'                ; dl contains the low byte of the remainder. Convert it to ASCII
    mov [ecx], dl              ; and store it in the buffer

    dec ecx                    ; move the output pointer to the previous address
    jmp .digit_loop             ; move on to the next loop

.exit_digit_loop:
    inc ecx
.exit_digit_loop1:
    ; if we get here, we've loaded the output into the buffer pointed to by ecx, just print it
    mov eax,4                ; select write syscall
    mov ebx,1                ; select output file handle
    mov edx,end_of_buffer
    sub edx,ecx              ; calculate the difference between ecx and the buffer's end: that's the length of the string
    ; address of data is already in ecx
    int 80h                  ; do it

    pop ebp
    ret 4

; Just print a newline. No parameters, no return
print_newline:
    push ebp          ; set up stack frame
    mov ebp,esp

    mov eax,4         ; select syscall 4, write
    mov ebx,1         ; select file descriptor 1, stdout
    mov ecx,buffer    ; point to datain buffer
    mov edx,1         ; just print one character
    mov byte [ecx], 10 ; we want the newline character
    int 80h            ; do it
    pop ebp            ; clean up and leave
    ret

exit:
    mov eax,1                 ; select exit syscall
    mov ebx,0                 ; return value
    int 80h                   ; do it
    ; no return