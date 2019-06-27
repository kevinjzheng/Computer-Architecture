sum_array:
push ebp
mov ebx, [ebp+12]    ; set ebx to 1st parameter (32-bit pointer)
mov ecx, [ebp+8]   ; set ebx to 2nd parameter (number of elements in array)
cmp ecx, 0          ; if lenth == 0
je basecase
add ebx, 4          ; advance array pointer
dec ecx             ; decrement number of elements by 1
push ebx
push ecx
call sum_array
mov edx, [ebx]      ; set edx to dereference a
add edx, eax        ; add edx to result given by recursive call
mov eax, edx        ; move result into eax
jmp done

basecase:
mov eax, 0          ; return 0

done:
pop ebp
ret 8
