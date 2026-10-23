global _start

section .data
    wynik db '0', 10       ; Cyfra i znak nowej linii.

section .text
_start:
    ; Dodaj dwie liczby.
    mov rax, 3
    add rax, 4

    ; Zamien wynik 0–9 na znak ASCII.
    add al, '0'
    mov [wynik], al

    ; Wypisz wynik — wersja 64-bitowa.
    mov rax, 1             ; Numer wywolania write.
    mov rdi, 1             ; Standardowe wyjscie.
    mov rsi, wynik         ; Adres tekstu.
    mov rdx, 2             ; Cyfra i nowa linia.
    syscall

    ; Odpowiednik dla interfejsu 32-bitowego:
    ; mov eax, 4           ; Numer wywolania write.
    ; mov ebx, 1           ; Standardowe wyjscie.
    ; mov ecx, wynik       ; Adres tekstu — 32 bity.
    ; mov edx, 2           ; Cyfra i nowa linia.
    ; int 0x80

    ; Zakoncz program — wersja 64-bitowa.
    mov rax, 60            ; Numer wywolania exit.
    mov rdi, 0             ; Kod zakonczenia — sukces.
    syscall

    ; Odpowiednik dla interfejsu 32-bitowego:
    ; mov eax, 1           ; Numer wywolania exit.
    ; mov ebx, 0           ; Kod zakonczenia — sukces.
    ; int 0x80
