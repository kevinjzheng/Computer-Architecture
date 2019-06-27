; Compile like this:
;     nasm -f elf -gstabs ack.asm && ld -o ack -m elf_i386 ack.o
; Run like this:
;     ./ack


; Gives us various IO functions
%include "io.asm"

section .data
message_m: db "Please enter a value for m: "
message_m_len equ $-message_m
message_n: db "Please enter a value for n: "
message_n_len equ $-message_n

result_f1: db "f1 result: "
result_f1_len equ $-result_f1

result_f2: db "f2 result: "
result_f2_len equ $-result_f2


; The text section is for code
section .text
global _start

; function f1
f1:
    ;; TODO Your code here
    ;; Take parameters m and n from the stack
    ;; Leave result in eax
    ;; Don't forget to include the stack frame
    push ebp
    mov ebp, esp

    mov ebx, [ebp+12]         ;; move parameter m into ebx
    mov ecx, [ebp+8]          ;; move parameter n into ecx

    cmp ebx, 0                ;; if m = 0
    je f1basecase1

    cmp ecx, 1                ;; if n = 1
    je f1basecase2

    ;;modifying parameters for recursive call
    sub ebx, 1                ;; m-1
    add ecx, 1                ;; n+1
    push ebx                  ;; pushing these values to stack as paramaters
    push ebx
    push ecx
    call f1
    push eax                   ;; result of this f1 will be n for the next f1
    call f1
    jmp f1done

    f1basecase1:
    mov eax, ecx              ;; return n
    jmp f1done

    f1basecase2:
    mov edx, 1
    shl edx, cl
    mov eax,edx               ;; return 2^m
    jmp f1done

    f1done:
    mov esp, ebp
    pop ebp
    ret 8

f2:
    ;; TODO Your code here
    ;; Take parameters m and n from the stack
    ;; Leave result in eax
    ;; Don't forget to include the stack frame
    push ebp
    mov ebp, esp

    mov ebx, [ebp+12]         ;; move parameter m into ebx
    mov ecx, [ebp+8]          ;; move parameter n into ecx

    cmp ecx, 0                ;; if n = 0
    je f2basecase1

    cmp ebx, 0                ;; if m = 0
    je f2basecase2

    cmp ebx, 1                ;; if m =1
    je f2basecase3

    sub ebx, 1
    push ebx
    add ebx, 1
    sub ecx, 1
    push ebx
    push ecx
    call f2
    push eax
    call f2
    jmp f2done

    f2basecase1:
    mov eax, 1
    jmp f2done

    f2basecase2:
    mov eax, 1
    jmp f2done

    f2basecase3:
    add ecx, ecx
    mov eax, ecx
    jmp f2done

    f2done:
    mov esp, ebp
    pop ebp
    ret 8

; The entrypoint of the program. Test the functions and print the result
_start:


    ; Prompt the user to enter a number for m
    mov eax,4
    mov ebx,1
    mov ecx,message_m
    mov edx,message_m_len
    int 80h
    call read_int
    push eax     ; push value of m


    ; Prompt the user to enter a number for n
    mov eax,4
    mov ebx,1
    mov ecx,message_n
    mov edx,message_n_len
    int 80h
    call read_int
    push eax      ; push value of n

    pop ebx       ; pop value of n
    pop ecx       ; pop value of m

    push ecx      ; set up params for f1 call
    push ebx
    push ecx      ; set up params for f2 call
    push ebx
    ; At this point, the stack contains m,n,m,n
    ; The first m and n will be consumed by f1
    ; The second by f2


    ; Call f1
    call f1
    push eax      ; push the result for print_int
    mov eax,4
    mov ebx,1
    mov ecx,result_f1
    mov edx,result_f1_len
    int 80h
    call print_int ; print_the result
    call print_newline


    ; Call f2
    call f2
    push eax      ; push the result for print_int
    mov eax,4
    mov ebx,1
    mov ecx,result_f2
    mov edx,result_f2_len
    int 80h
    call print_int ;print the result
    call print_newline


; We're done, tell the OS to kill us
    call exit
