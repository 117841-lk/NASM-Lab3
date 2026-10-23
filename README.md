# NASM-Lab3 — Procedury

Trzecie laboratorium z NASM przygotowane do pracy w środowisku GitHub Codespaces.

Celem zajęć jest zapoznanie studenta z:
- tworzeniem i wywoływaniem procedur,
- instrukcjami `call` i `ret`,
- przekazywaniem argumentów przez rejestry,
- zwracaniem wyniku procedury,
- wykorzystaniem jednej procedury do przetwarzania różnych danych.

## Środowisko

Korzystamy ze skonfigurowanego środowiska GitHub Codespaces oraz debuggera GDB dostępnego w VS Code.

Programy piszemy w NASM dla Linuxa x86-64.

Plik `src/main.asm` zawiera program początkowy, który dodaje dwie liczby i wypisuje wynik na konsoli.

Aktywny kod wykorzystuje instrukcję `syscall`. Zakomentowane fragmenty z `int 0x80` służą wyłącznie do porównania interfejsów wywołań systemowych.

## Uruchamianie i debugowanie

1. Otwórz plik `src/main.asm`.
2. Ustaw breakpoint przy pierwszej instrukcji programu.
3. Otwórz panel Run and Debug po lewej stronie edytora.
4. Wybierz skonfigurowane uruchomienie programu i rozpocznij debugowanie.

Możesz również otworzyć paletę poleceń za pomocą `Ctrl+Shift+P` i wybrać `Debug: Start Debugging`.

Podczas pracy z procedurami używaj Step Into, aby wejść do wywoływanej procedury i wykonywać jej instrukcje krokowo.

## Zadanie 1. Dodawanie w procedurze

Zmodyfikować program początkowy tak, aby dodawanie dwóch liczb odbywało się we własnej procedurze `add_numbers`.

Przyjąć następujący sposób przekazywania danych:
- `rdi` — pierwsza liczba;
- `rsi` — druga liczba;
- `rax` — wynik dodawania.

W programie głównym zastąpić bezpośrednie dodawanie przygotowaniem argumentów i wywołaniem procedury:

```nasm
    mov rdi, 3
    mov rsi, 4
    call add_numbers
```

Po powrocie z procedury wykorzystać istniejący kod zamiany wyniku na znak ASCII i wypisywania na konsoli.

### Przykład — procedura odejmująca dwie liczby

Poniższa procedura oblicza różnicę pierwszego i drugiego argumentu:

```nasm
; Argumenty:
;   rdi — pierwsza liczba
;   rsi — druga liczba
; Wynik:
;   rax — roznica: rdi - rsi

subtract_numbers:
    mov rax, rdi
    sub rax, rsi
    ret
```

Przykładowe wywołanie:

```nasm
    mov rdi, 8
    mov rsi, 3
    call subtract_numbers

    ; W tym miejscu rax zawiera 5.
```

Definicję własnej procedury umieścić w sekcji `.text`, za kodem kończącym program. Procedura powinna kończyć się instrukcją `ret`.

### Do wykonania

1. Napisać procedurę `add_numbers`.
2. Wywołać ją dla argumentów `3` i `4`.
3. Wypisać otrzymany wynik na konsoli.
4. Sprawdzić działanie dla innej pary liczb, której suma mieści się w zakresie `0–9`.
5. W debuggerze wejść do procedury i sprawdzić wartości argumentów oraz wyniku.
6. Zaobserwować wartość `rsp` przed wykonaniem `call`, po wejściu do procedury oraz po wykonaniu `ret`.

Kod wypisywania z programu początkowego obsługuje tylko wynik od `0` do `9`.

## Zadanie 2. Większa z dwóch liczb

Napisać procedurę `max_numbers`, która zwraca większą z dwóch 64-bitowych liczb całkowitych ze znakiem.

Przyjąć:
- `rdi` — pierwsza liczba;
- `rsi` — druga liczba;
- `rax` — większa z przekazanych liczb.

W procedurze wykorzystać instrukcję porównania oraz skok warunkowy.

Wywołać tę samą procedurę dla następujących par:

| Pierwsza liczba | Druga liczba | Oczekiwany wynik |
|---:|---:|---:|
| 7 | 5 | 7 |
| -8 | 3 | 3 |
| 4 | 4 | 4 |

Do programu dodać miejsce na wyniki:

```nasm
section .bss
    max1 resq 1
    max2 resq 1
    max3 resq 1
```

### Do wykonania

1. Napisać procedurę `max_numbers`.
2. Wywołać ją dla każdej pary argumentów.
3. Bezpośrednio po każdym wywołaniu zapisać wynik do odpowiedniej zmiennej: `max1`, `max2` lub `max3`.
4. Sprawdzić wyniki w debuggerze.
5. Wypisać na konsoli jeden z zapisanych wyników, wykorzystując kod z programu początkowego.

Przykład zapisania wyniku procedury do pamięci:

```nasm
    mov [max1], rax
```

## Zadanie 3. Suma elementów tablicy

Napisać procedurę `sum_array`, która oblicza sumę elementów tablicy 64-bitowych liczb całkowitych ze znakiem.

Przyjąć:
- `rdi` — adres pierwszego elementu tablicy;
- `rsi` — liczba elementów;
- `rax` — suma elementów.

Do istniejącej sekcji `.data` dodać:

```nasm
    array1 dq 3, 4, 1, 2, 5
    array2 dq -2, 7, -5, 10
```

Do sekcji `.bss` dodać:

```nasm
    sum1 resq 1
    sum2 resq 1
```

Przykładowe wywołanie dla pierwszej tablicy:

```nasm
    mov rdi, array1        ; Adres pierwszego elementu.
    mov rsi, 5             ; Liczba elementow.
    call sum_array
    mov [sum1], rax
```

### Do wykonania

1. Napisać procedurę wykorzystującą pętlę.
2. Adres tablicy i liczbę elementów pobierać z argumentów — nie wpisywać ich na stałe wewnątrz procedury.
3. Uwzględnić, że jeden element tablicy zajmuje 8 bajtów.
4. Wywołać tę samą procedurę dla obu tablic.
5. Zapisać wyniki w zmiennych `sum1` i `sum2`.
6. Sprawdzić wyniki w debuggerze.
7. Dla liczby elementów równej zero zwrócić `0`, bez odczytywania elementów tablicy.

Oczekiwane wyniki:
- `sum1 = 15`;
- `sum2 = 10`.

W tym zadaniu nie trzeba wypisywać wyników na konsoli. Kod z programu początkowego obsługuje tylko pojedynczą cyfrę, a nie liczby wielocyfrowe.

## Objaśnienie `call` i `ret`

### Wywołanie i powrót

```nasm
    call nazwa_procedury
```

Instrukcja `call` zapisuje na stosie adres powrotu i przekazuje sterowanie do wskazanej procedury.

```nasm
    ret
```

Instrukcja `ret` pobiera ze stosu adres powrotu i wznawia wykonanie programu od instrukcji następującej po wywołaniu.

### Przekazywanie danych

W zadaniach przyjmujemy:
- pierwszy argument w `rdi`;
- drugi argument w `rsi`;
- wynik w `rax`.

Argumenty należy przygotować przed wykonaniem `call`.

Wynik potrzebny po kolejnych wywołaniach należy wcześniej zachować, na przykład w pamięci. Dotyczy to również wypisywania: instrukcja `mov rax, 1`, przygotowująca wywołanie `write`, nadpisuje poprzednią zawartość `rax`.

## Pliki wynikowe

Pliki wynikowe kompilacji nie powinny być commitowane do repozytorium. Powinny być pomijane przez `.gitignore`.
