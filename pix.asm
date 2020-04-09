global pix

%macro PUSH_REGS 0
  push rdi
  push rsi
  push rbx
  push rbp
  push rsp
  push r12
  push r13
  push r14
  push r15
%endmacro

%macro POP_REGS 0
  pop r15
  pop r14
  pop r13
  pop r12
  pop rsp
  pop rbp
  pop rbx
  pop rsi
  pop rdi
%endmacro

; wynik w rax
; modyfikuje rax, rdx, rbx
%macro div_frac 2
  xor eax, eax
  mov rdx, %1
  mov rbx, %2
  div rbx
%endmacro

; Nie zachowuje %2, wynik w r8.
; modyfikuje rax, rdx, r8, rcx
%macro pow_mod 2
  test %1, %1
  jz %%check_mod
  mov rax, 0x10
  xor edx, edx
  div %2
  test rdx, rdx
  mov r8, rdx
  jz %%exit
  mov r8, 1
  ;test %2, %2
  ;jz %%exit
  mov rcx, rdx
%%main_loop:
  test %1, 1 ; y nieparzysty
  jz %%even_y
  mov rax, r8
  xor edx, edx
  mul rcx
  div %2
  mov r8, rdx
%%even_y:
  ;imul rcx, rcx
  mov rax, rcx
  mul rax
  xor edx, edx
  ;mov rax, rcx
  div %2
  mov rcx, rdx
  shr %1, 1
  jnz %%main_loop
  jmp %%exit
%%check_mod:
  mov r8, 1
  xor ecx, ecx
  cmp %2, 1
  cmove r8, rcx
%%exit:
%endmacro

; ; %1 - n, %2 - j
; %macro s_j 2
;   xor r9d, r9d ; <--------- wynik
;   xor r14d, r14d ; k
; %%first_loop:
;   cmp r14, %1
;   ja %%first_loop_exit
;   mov rdi, r14 ; rdi = mianownik
;   shl rdi, 3
;   add rdi, %2
;   mov rbp, %1
;   sub rbp, r14 ; n-k
;   pow_mod rbp, rdi
;   div_frac r8, rdi
;   add r9, rax ; rax??????
;   inc r14 ; zwieksz k
;   jmp %%first_loop
; %%first_loop_exit:
;   mov rbp, 0x1000000000000000
;   mov rcx, rbp ; rcx = licznik
; %%second_loop:
;   mov rdi, r14
;   shl rdi, 3
;   add rdi, %2
;   xor rdx, rdx
;   mov rax, rcx
;   div rdi
;   test rax, rax
;   jz %%exit
;   add r9, rax ; rdx????
;   xor rdx, rdx
;   mov rax, rcx
;   mul rbp
;   mov rcx, rdx
;   inc r14
;   jmp %%second_loop
; %%exit:
; %endmacro

%macro pi 0
  xor r10d, r10d
  push r13
  mov r13, 1
  call s_j
  lea r10, [r9 + r9 * 1]
  mov r13, 4
  call s_j
  sub r10, r9
  add r10, r10
  mov r13, 5
  call s_j
  sub r10, r9
  mov r13, 6
  call s_j
  sub r10, r9
  pop r13
%endmacro

section .text
align 8
s_j:
  xor r9d, r9d ; <--------- wynik
  xor r14d, r14d ; k
.first_loop:
  cmp r14, r15
  ja .first_loop_exit
  mov rdi, r14 ; rdi = mianownik
  shl rdi, 3
  add rdi, r13
  mov rbp, r15
  sub rbp, r14 ; n-k
  pow_mod rbp, rdi
  div_frac r8, rdi
  add r9, rax ; rax??????
  inc r14 ; zwieksz k
  jmp .first_loop
.first_loop_exit:
  mov rbp, 0x1000000000000000
  mov rcx, rbp ; rcx = licznik
.second_loop:
  mov rdi, r14
  shl rdi, 3
  add rdi, r13
  xor rdx, rdx
  mov rax, rcx
  div rdi
  test rax, rax
  jz .exit
  add r9, rax ; rdx????
  xor rdx, rdx
  mov rax, rcx
  mul rbp
  mov rcx, rdx
  inc r14
  jmp .second_loop
.exit:
  ret
pix:
  PUSH_REGS
  lea r11, [rdi]
  mov r13, rdx
  push rdi
  push rdx
pix_loop:
  mov r12, 1
  lock xadd [rsi], r12
  cmp r12, r13
  jae exit
  mov r15, r12
  shl r15, 3
  pi
  shr r10, 32
  mov dword [r11 + 4 * r12], r10d
  jmp pix_loop
exit:
  pop rdx
  pop rdi
  POP_REGS
  xor eax, eax
  ret