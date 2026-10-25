section .data
    array dq 3, 4, 1, 2, 5

section .bss
    suma resq 1

section .text
_start:
    mov rbx, array ; adres bierzącego elementu
    mov rcx, 5 ; licznik, 5 elementów w tablicy
    mov [suma], 0
    _petla:
        mov rdi, rax 
        mov rsi, [rbx]
        call add_numbers
        add rbx, 8
    loop _petla
    mov [suma], al
    _wypisz:
        xor rdx, rdx
        cmp rax, 0
        jz _wypisz_koniec
        mov rcx, 10 ;dzielnik
        div rcx
        add edx, '0'

    _wypisz_koniec:

        

    mov rax, 60
    mov rdi, 0
    syscall


add_numbers:
    mov rax, rdi
    add rax, rsi
    ret
