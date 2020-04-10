global pix
extern pixtime

; Wrzuca na stos rejestry zachowywane przez funkcje.
%macro PUSH_REGS 0
  push rbx
  push rbp
  push r12
  push r13
  push r14
  push r15
%endmacro

; Zdejmuje ze stosu rejestry zachowywane przez funkcje.
%macro POP_REGS 0
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  pop rbx
%endmacro

; Oblicza część ułamkową liczby %1 / %2.
; Modyfikuje rejestry rax, rdx, rcx.
; Wynik przekazuje w rejestrze rax.
%macro DIV_FRAC 2
  xor eax, eax
  mov rdx, %1
  mov rcx, %2
  div rcx
%endmacro

; Oblicza (16 ^ %1) mod %2 i przekazuje wynik w r8.
; Modyfikuje rejestry rax, rdx, rcx, r8 i rejestr pod %1
%macro POW_MOD 2
  test %1, %1
  jz %%check_mod ; Wykładnik jest równy 0.
  mov rax, 16
  xor edx, edx
  div %2
  test rdx, rdx ; Sprawdź, czy mod dzieli 16.
  mov r8, rdx
  jz %%exit ; Mod dzieli 16. Pod r8 mamy wartość 0.
  mov r8, 1 ; Na początku wynik to 1.
  mov rcx, rdx ; Pod rcx mamy: 16 mod %2.
%%main_loop:
  test %1, 1 ; Sprawdzamy parzystość, czyli ostatni bit.
  jz %%even_y ; Wykładnik jest parzysty.
  mov rax, r8
  xor edx, edx
  mul rcx
  div %2
  mov r8, rdx ; Pod r8 mamy (r8 * 16) mod %2.
%%even_y:
  mov rax, rcx
  mul rax ; Podstawa razy podstawa.
  xor edx, edx
  div %2
  mov rcx, rdx ; Pod rcx mamy (16 ^ x) mod %2.
  shr %1, 1 ; Podziel wykładnik przez 2.
  jnz %%main_loop
  jmp %%exit ; Wykładnik osiągnął wartość 0.
%%check_mod: ; Wykładnik jest równy 0.
  mov r8, 1
  xor ecx, ecx
  cmp %2, 1
  cmove r8, rcx ; Jeśli mod jest równe 1, to wynik to 0, wpp. wynik to 1.
%%exit:
%endmacro

; Oblicza 8 cyfr rozwinięcia dziesiętnego liczby pi
; od miejsca przekazanego w rejestrze r15.
; Modyfikuje rejestry rbx, r10 i rejestry modyfikowane przez procedurę s_j.
; Wynik zwraca w rejestrze r10.
; Dokładniej, oblicza 4S_1 - 2S_4 - S_5 - S_6, ale w taki sposób: (2S_1 - S_4) + (2S_1 - S_4) - S_5 - S_6.
%macro PI 0
  xor r10d, r10d
  mov rbx, 1 ; W rbx przekazujemy wartość j do procedury s_j.
  call s_j
  lea r10, [r9 + r9 * 1] ; W r9 dostajemy wynik procedury s_j.
  mov rbx, 4
  call s_j
  sub r10, r9
  add r10, r10
  mov rbx, 5
  call s_j
  sub r10, r9
  mov rbx, 6
  call s_j
  sub r10, r9
%endmacro

; Wrzuca na stos rejestry z parametrami i woła funkcję pixtime.
%macro TIME 0
  push rdi
  push rsi
  push rdx
  rdtsc ; Wynik w edx:eax.
  shl rdx, 32
  add rdx, rax
  mov rdi, rdx ; Łączny wynik zapisujemy na rdi, czyli na pierwszym parametrze.
  call pixtime
  pop rdx
  pop rsi
  pop rdi
%endmacro

section .text
; Oblicza S_j i przekazuje wynik w r9.
; Modyfikuje rejestry rax, rdi, rbp, rcx, r9,
; r14 i inne rejestry modyfikowane z makr DIV_FRAC i POW_MOD.
; Dostaje jako argumenty: liczbę n w rejestrze r15 i liczbę j w rejestrze rbx.
s_j:
  xor r9d, r9d
  xor r14d, r14d ; Pod r14 mamy k.
.first_loop:
  cmp r14, r15
  ja .first_loop_exit ; k >= n
  mov rdi, r14 ; W rdi mamy mianownik.
  shl rdi, 3
  add rdi, rbx ; rdi = 8 * k + j
  mov rbp, r15
  sub rbp, r14 ; rbp = n - k
  POW_MOD rbp, rdi
  DIV_FRAC r8, rdi ; W r8 jest wynik POW_MOD.
  add r9, rax ; W rax jest wynik DIV_FRAC.
  inc r14
  jmp .first_loop
.first_loop_exit:
  mov rbp, 0x1000000000000000 ; Część ułamkowa liczby 1/16.
  mov rcx, rbp ; W rcx mamy licznik.
.second_loop:
  mov rdi, r14
  shl rdi, 3
  add rdi, rbx ; rdi = 8 * k + j
  xor rdx, rdx
  mov rax, rcx
  div rdi
  test rax, rax
  jz .exit ; rcx / rdi = 0
  add r9, rax ; Dodajemy do wyniku rcx / rdi
  xor rdx, rdx
  mov rax, rcx
  mul rbp
  mov rcx, rdx ; W rcx mamy część ułamkową liczby (rcx / rdi) * (1 / 16).
  inc r14
  jmp .second_loop
.exit:
  ret
align 8
pix:
  TIME ; Wywołaj funkcję pixtime.
  PUSH_REGS
  lea r11, [rdi] ; Adres tablicy, do której zapisujemy wyniki.
  mov r13, rdx ; Wartość parametru max.
  push rdi ; Wrzucam na stos rdi i rdx na wszelki wypadek.
  push rdx
pix_loop:
  mov r12, 1 ; Wartość, którą dodajemy do indeksu elementu w tablicy ppi.
  lock \
  xadd [rsi], r12 ; Atomowe pobranie wartości z pidx do r12 i dodanie 1 do pidx.
  cmp r12, r13
  jae exit ; Indeks jest większy lub równy max, więc kończymy.
  mov r15, r12
  shl r15, 3 ; r15 = 8 * m
  PI
  shr r10, 32
  mov dword [r11 + 4 * r12], r10d ; Zapisujemy wynik do odpowiedniego miejsca w tablicy.
  jmp pix_loop
exit:
  pop rdx
  pop rdi
  POP_REGS
  xor eax, eax ; Zwróć NULL.
  TIME ; Wywołaj funkcję pixtime.
  ret