section .data
numbers_size: dd 8
numbers: dd 10, 34, 55, 106, 44, 0, 45, 400
section .text
global _start
_start:
; Your code here

xor eax, eax                ; set eax to 0
xor ebx, ebx                ; set ebx to 0
xor edx, edx                ; set edx to 0
mov ecx, numbers

additionLoop:
add eax, [ecx]              ; add first element in numbers
add ebx, 1                  ; add 1 to eax
add ecx, 4                  ; add 4 to numbers address
cmp ebx, [numbers_size]     ; compares size of number array to eax
jne additionLoop
div ebx
