strlen:
  push ebp
  mov ecx, ebp+8  ; give ecx address of the parameter
  xor ebx, ebx    ; set ebx to 0
  loop:
  mov eax, [ecx]  ; set eax to value at ebp+8
  inc ebx         ; counter
  inc ecx         ; increment address by 1
  cmp eax, 0
  jne loop
  mov eax, ebx    ; put count into eax for return
  pop ebp
  ret 4

print_longer:
  push ebp
  mov ebp, esp
  mov ebx, [ebp+8]  ; s2
  push ebx
  call strlen
  mov ecx, eax    ; set ecx to length of s2
  mov ebx, [ebp+12] ; s1
  push ebx
  call strlen
  mov edx, eax    ; set edx to length of s1
  ; prepping the syscall
  mov eax, 4
  mov ebx, 1
  ; if ecx is less than edx, edx is longer (s1)
  cmp ecx, edx
  jl assign
  mov ecx, [ebp+12]
  mov edx, ecx
  assign:
  mov ecx, [ebp+8]

  int 80h
  pop ebp
  ret 8
