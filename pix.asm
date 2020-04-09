SYS_WRITE equ 1
STDOUT equ 1

global pix

%macro PRINT 2
  mov     rsi, %1
  mov     eax, SYS_WRITE
  mov     edi, STDOUT
  mov     rdx, %2
  syscall
%endmacro

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

%macro largest_pow 1
  test %1, %1
  xor eax, eax
  je %%exit
  mov eax, 1
  cmp rax, %1
%%shift_left:
  shl rax, 1
  cmp rax, %1
  jbe %%shift_left
  shr rax, 1
%%exit:
%endmacro

; Nie zachowuje %2, wynik w r8.
; modyfikuje rax, rdx, r8, rcx
%macro pow_mod 3
  test %2, %2
  jz %%check_mod
  mov rax, %1
  xor edx, edx
  div %3
  test rdx, rdx
  mov r8, rdx
  jz %%exit
  mov r8, 1
  ;test %2, %2
  ;jz %%exit
  mov rcx, rdx
%%main_loop:
  test %2, 1 ; y nieparzysty
  jz %%even_y
  mov rax, r8
  xor edx, edx
  mul rcx
  div %3
  mov r8, rdx
%%even_y:
  ;imul rcx, rcx
  mov rax, rcx
  mul rax
  xor edx, edx
  ;mov rax, rcx
  div %3
  mov rcx, rdx
  shr %2, 1
  jnz %%main_loop
  jmp %%exit
%%check_mod:
  mov r8, 1
  xor ecx, ecx
  cmp %3, 1
  cmove r8, rcx
%%exit:
%endmacro

; %1 - n, %2 - j
%macro s_j 2
  xor r9d, r9d ; <--------- wynik
  xor esi, esi ; k
%%first_loop:
  cmp rsi, %1
  ja %%first_loop_exit
  mov rdi, rsi ; rdi = mianownik
  shl rdi, 3
  add rdi, %2
  mov rbp, %1
  sub rbp, rsi ; n-k
  pow_mod 16, rbp, rdi
  div_frac r8, rdi
  add r9, rax ; rax??????
  inc rsi ; zwieksz k
  jmp %%first_loop
%%first_loop_exit:
  mov rbp, 0x1000000000000000
  mov rcx, rbp ; rcx = licznik
%%second_loop:
  mov rdi, rsi
  shl rdi, 3
  add rdi, %2
  xor rdx, rdx
  mov rax, rcx
  div rdi
  test rax, rax
  jz %%exit
  add r9, rax ; rdx????
  xor rdx, rdx
  mov rax, rcx
  mul rbp
  mov rcx, rdx
  inc rsi
  jmp %%second_loop
%%exit:
%endmacro

%macro pi 1
  xor r10d, r10d
  s_j %1, 1
  lea r10, [r9 + r9 * 1]
  s_j %1, 4
  sub r10, r9
  add r10, r10
  s_j %1, 5
  sub r10, r9
  s_j %1, 6
  sub r10, r9
%endmacro

section .rodata
  jol_msg db "jol"

section .bss
  jol: resb 16

section .text
align 8
pix:
  lea rcx, [rdi]
  mov r8, [rsi]
  xor r9, r9
  PUSH_REGS
pix_loop:
  cmp r9, rdx
  jae exit
  mov dword [rcx + 4 * r9], 50
  inc r9
  jmp pix_loop
exit:
  mov r12, 234
  mov r13, 4
  mov r14, 543
  ;div_frac r12, r13
  ;largest_pow r13
  ;pow_mod r12, r13, r14
  ;mov rax, rdx
  ;mov rax, r8
  ;mov rax, r14
  ;mov r10, 8
  ;mul r10
  ;s_j 24, 6
  ;mov rax, r9
  xor r9, r9
  pi 24
  mov rax, r10
  ;pow_mod r12, r13, r14
  ;mov rax, r8
  POP_REGS
  ret