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
  mov rax, %1
  xor edx, edx
  div %3
  test rdx, rdx
  mov r8, rdx
  jz %%exit
  mov r8, 1
  test %2, %2
  jz %%exit
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
%%exit:
%endmacro

; %1 - n, %2 - j
%macro s_j 2
  xor r9d, r9d ; <--------- wynik
  xor esi, esi ; k
%%first_loop:
  cmp rsi, %1
  ja %%first_loop_exit
  mov rax, rsi
  mul 8
  mov rdi, rax ; rdi = mianownik
  add rdi, %2
  mov rbp, %1
  sub rbp, rsi ; n-k
  pow_mod 16, rbp, rdi
  div_frac r8, rdi
  add r9, rdx ; rax??????
  inc rsi ; zwieksz k
%%first_loop_exit:
%endmacro

section .rodata
  jol_msg db "jol"

section .bss
  jol: resb 16

section .text
align 8
pix:
  PUSH_REGS
  lea rcx, [rdi]
  mov r8, [rsi]
  xor r9, r9
pix_loop:
  cmp r9, rdx
  jae exit
  mov dword [rcx + 4 * r9], 50
  inc r9
  jmp pix_loop
exit:
  mov r12, 56
  mov r13, 0
  mov r14, 9
  ;div_frac r12, r13
  ;largest_pow r13
  pow_mod r12, r13, r14
  ;mov rax, rdx
  mov rax, r8
  POP_REGS
  ret