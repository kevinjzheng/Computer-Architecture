section .bss
text_input: resb 20
section .data

askName: db "Please enter your name: "
askName_end:
askName_len equ askName_end - askName

greeting: db "Nice to meet you, "
greeting_end:
greeting_len equ greeting_end - greeting

section .text
global _start
_start:

mov eax, 4
mov ebx, 1
mov ecx, askName
mov edx, askName_len
int 80h

mov eax, 3
mov ebx, 0
mov ecx, text_input
mov edx, 20
int 80h

mov eax, 4
mov ebx, 1
mov ecx, greeting
mov edx, greeting_len
int 80h

mov eax, 4
mov ebx, 1
mov ecx, text_input
mov edx, 20
int 80h

endprogram:
mov eax, 1
mov ebx, 1
int 80h
