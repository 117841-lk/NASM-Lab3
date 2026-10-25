global _start

section .data
    wynik db '0', 10       ; Cyfra i znak nowej linii.

section .text
_start:
    ; Dodaj dwie liczby.
    mov rdi, 3
    add rsi, 4
    call add_numbers

    ; Zamien wynik 0–9 na znak ASCII.
    add al, '0'
    mov [wynik], al

    ; Wypisz wynik — wersja 64-bitowa.
    mov rax, 1             ; Numer wywolania write.
    mov rdi, 1             ; Standardowe wyjscie.
    mov rsi, wynik         ; Adres tekstu.
    mov rdx, 2             ; Cyfra i nowa linia.
    syscall

    ; Zakoncz program — wersja 64-bitowa.
    mov rax, 60            ; Numer wywolania exit.
    mov rdi, 0             ; Kod zakonczenia — sukces.
    syscall

add_numbers:
    mov rax, rdi
    add rax, rsi
    ret
    
