# NASM-Lab3

Trzecie laboratorium z NASM przygotowane do pracy w środowisku GitHub Codespaces.

## Cel laboratorium

Celem zajęć jest zapoznanie studenta z:

- tworzeniem i wywoływaniem procedur,
- instrukcjami `call` i `ret`,
- przekazywaniem argumentów i zwracaniem wyniku przez rejestry,
- przechodzeniem po elementach tablicy,
- wywoływaniem procedury w pętli,
- przekazywaniem adresów pamięci do procedury,
- zapisywaniem wyników obliczeń w pamięci,
- analizą działania programu krok po kroku w debuggerze GDB.

W przykładach i zadaniach korzystamy z pełnych rejestrów 64-bitowych: `rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi` i `rsp`.

## Struktura projektu

- `src/main.asm` — plik zawierający główną implementację programu w asemblerze NASM,
- `Makefile` — plik opisujący sposób kompilacji i budowania programu,
- `.vscode/launch.json` — konfiguracja sesji uruchomieniowych i debugowania w edytorze VS Code,
- `.vscode/tasks.json` — konfiguracja zadań automatyzujących proces budowania w VS Code,
- `.devcontainer/` — katalog zawierający konfigurację środowiska uruchamianego w GitHub Codespaces.

## Budowanie programu

Program można zbudować ręcznie poleceniem:

```text
make
```

W standardowej konfiguracji projektu ręczne wywołanie `make` nie jest jednak konieczne przed uruchomieniem debugowania w VS Code.

Jeżeli w pliku `launch.json` ustawiono parametr `preLaunchTask`, edytor automatycznie uruchomi zadanie budowania przed rozpoczęciem sesji debugowania.

## Uruchamianie programu

Program jest uruchamiany z poziomu debuggera w VS Code.

Najprostszy sposób uruchomienia:

1. Otwórz panel **Run and Debug**.
2. Wybierz konfigurację debugowania.
3. Naciśnij `F5`.

Panel debugowania można również otworzyć skrótem `Ctrl+Shift+D`.

Uruchomienie debugowania jest dostępne także z poziomu palety poleceń `Ctrl+Shift+P`.

## Program początkowy

Plik `src/main.asm` zawiera program, który:

1. Dodaje dwie liczby.
2. Zamienia wynik na kod ASCII cyfry.
3. Zapisuje go w pamięci.
4. Wypisuje cyfrę i znak nowej linii na konsoli.
5. Kończy działanie.

```nasm
global _start

section .data
    wynik dq 0             ; Miejsce na znak wyniku.
    nowa_linia db 10       ; Znak nowej linii.

section .text
_start:
    ; Dodaj dwie liczby.
    mov rax, 3
    add rax, 4

    ; Zamien wynik 0–9 na kod ASCII cyfry.
    add rax, '0'
    mov [wynik], rax

    ; Wypisz znak cyfry.
    mov rax, 1             ; Numer wywolania write.
    mov rdi, 1             ; Standardowe wyjscie.
    mov rsi, wynik         ; Adres znaku.
    mov rdx, 1             ; Liczba bajtow do wypisania.
    syscall

    ; Wypisz znak nowej linii.
    mov rax, 1
    mov rdi, 1
    mov rsi, nowa_linia
    mov rdx, 1
    syscall

    ; Zakoncz program.
    mov rax, 60            ; Numer wywolania exit.
    mov rdi, 0             ; Kod zakonczenia — sukces.
    syscall
```

Program powinien wypisać:

```text
7
```

### Wynik liczbowy a znak ASCII

Liczba `7` i znak `'7'` mają różne wartości.

Instrukcja:

```nasm
    add rax, '0'
```

zamienia liczbę z zakresu `0–9` na kod ASCII odpowiadającej jej cyfry.

Kod wypisywania w programie początkowym obsługuje wyłącznie wyniki od `0` do `9`. Nie obsługuje liczb wielocyfrowych ani ujemnych.

Zmienna `wynik` zajmuje 8 bajtów, aby można było zapisać do niej cały rejestr `rax`. Podczas wypisywania przekazujemy długość `1`, dlatego na konsolę trafia tylko pierwszy bajt, zawierający kod cyfry.

Zmienna `nowa_linia` zawiera jeden bajt o wartości `10`, czyli znak nowej linii.

## Procedury

Procedura jest wydzielonym fragmentem programu, który można wielokrotnie wywoływać dla różnych danych.

Instrukcja `call` zapisuje na stosie adres powrotu i przekazuje sterowanie do procedury.

Instrukcja `ret` pobiera adres powrotu ze stosu i wraca do instrukcji następującej po wywołaniu.

W przykładach przyjmujemy:

- `rdi` — pierwszy argument,
- `rsi` — drugi argument,
- `rax` — wynik.

Argumenty należy umieścić w rejestrach przed wykonaniem `call`.

### Przykład procedury odejmującej dwie liczby

```nasm
; Argumenty:
;   rdi — pierwsza liczba
;   rsi — druga liczba
; Wynik:
;   rax — roznica pierwszej i drugiej liczby

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

    ; Po powrocie rax zawiera 5.
```

Definicję procedury należy umieścić w sekcji `.text`, za kodem kończącym program.

### Rejestry podczas wywołania

Samo wywołanie procedury nie zapisuje automatycznie rejestrów ogólnego przeznaczenia.

Jeżeli procedura zmieni rejestr, jego wcześniejsza wartość nie zostanie automatycznie odtworzona przez `ret`.

W procedurze dodającej z zadań 2 i 3 należy zmieniać wyłącznie `rax` oraz flagi arytmetyczne. Dzięki temu rejestry przechowujące argumenty, licznik pętli i adres elementu pozostaną bez zmian.

Wynik potrzebny po kolejnym wywołaniu należy wcześniej zachować. Dotyczy to również wywołań systemowych — przygotowanie `write` wymaga wpisania numeru wywołania do `rax`, co nadpisuje wcześniejszy wynik obliczeń.

## Przechodzenie po elementach tablicy

Tablicę można umieścić w sekcji `.data`.

W poniższym przykładzie każdy element zadeklarowano za pomocą `dq`, więc zajmuje 8 bajtów. Aby przejść do następnego elementu, zwiększamy adres o `8`.

```nasm
global _start

section .data
    array dq 3, 4, 1, 2, 5

section .text
_start:
    mov rbx, array         ; Adres biezacego elementu.
    mov rcx, 5             ; Liczba elementow.

next_element:
    mov rax, [rbx]         ; Odczytaj biezacy element.

    ; Tutaj mozna przetworzyc odczytana wartosc.

    add rbx, 8             ; Przejdz do kolejnego elementu.
    loop next_element

    mov rax, 60
    mov rdi, 0
    syscall
```

Podczas debugowania należy obserwować:

- `rbx` — adres bieżącego elementu,
- `rcx` — licznik pozostałych iteracji,
- `rax` — wartość odczytanego elementu.

Należy rozróżniać zapis:

```nasm
    mov rbx, array         ; Umiesc adres tablicy w rbx.
    mov rax, [rbx]         ; Odczytaj wartosc spod tego adresu.
```

## Debugowanie

Podczas debugowania można obserwować:

- wartości rejestrów podczas obliczeń,
- zawartość pamięci przed zapisaniem wyniku i po nim,
- argumenty przygotowane przed wywołaniem procedury,
- przejście do procedury po wykonaniu `call`,
- wynik znajdujący się w `rax`,
- powrót do programu głównego po wykonaniu `ret`,
- zmiany adresu podczas przechodzenia po tablicy.

Aby wejść do procedury, należy użyć Step Into.

Step Over wykonuje całe wywołanie bez zatrzymywania się przy kolejnych instrukcjach procedury.

Przydatne polecenia GDB:

```text
break _start
run
si
info registers
display /i $pc
x/gx $rsp
```

W konsoli debugowania rozszerzenia C/C++ w VS Code polecenia GDB można poprzedzić przez `-exec`, na przykład:

```text
-exec info registers
-exec x/gx $rsp
```

## Zadania

### 1. Analiza programu początkowego w debuggerze

Przestudiować działanie programu początkowego, wykonując go instrukcja po instrukcji w debuggerze.

1. Ustawić breakpoint przy pierwszej instrukcji programu i uruchomić debugowanie.
2. Obserwować zawartość `rax` po wykonaniu instrukcji `mov rax, 3` oraz `add rax, 4`.
3. Sprawdzić wartość `rax` przed wykonaniem i po wykonaniu instrukcji `add rax, '0'`.
4. Sprawdzić, jak zmienia się zawartość pamięci pod etykietą `wynik` po wykonaniu `mov [wynik], rax`.
5. Przed pierwszym `syscall` odczytać wartości `rax`, `rdi`, `rsi` i `rdx`. Na podstawie komentarzy wyjaśnić rolę każdego z tych rejestrów.
6. Wykonać wywołanie wypisujące cyfrę i sprawdzić wynik w konsoli.
7. Wskazać fragment wypisujący znak nowej linii.
8. Wskazać instrukcje odpowiedzialne za zakończenie programu.
9. Zmienić dodawane liczby na inną parę, której suma mieści się w zakresie `0–9`, i ponownie sprawdzić działanie programu.

Na podstawie obserwacji opisać różnicę między wynikiem liczbowym a znakiem ASCII wypisywanym na konsoli.

### 2. Dodawanie dwóch liczb w procedurze

Na podstawie przykładu procedury odejmującej napisać własną procedurę `add_numbers`, która dodaje dwie liczby.

Przyjąć:

- `rdi` — pierwsza liczba,
- `rsi` — druga liczba,
- `rax` — wynik dodawania.

Zmodyfikować program początkowy tak, aby zamiast bezpośredniego dodawania wykonywał:

```nasm
    mov rdi, 3
    mov rsi, 4
    call add_numbers
```

Po powrocie z procedury wykorzystać istniejący kod zamiany wyniku na kod ASCII i wypisywania na konsoli.

Wymagania:

1. Procedurę umieścić w sekcji `.text`, za kodem kończącym program.
2. Zakończyć procedurę instrukcją `ret`.
3. W procedurze zmieniać wyłącznie `rax` oraz flagi arytmetyczne.
4. Sprawdzić działanie dla kilku par liczb, których suma mieści się w zakresie `0–9`.
5. W debuggerze użyć Step Into, aby wejść do procedury.
6. Zaobserwować wartość `rsp` przed wykonaniem `call`, po wejściu do procedury oraz po wykonaniu `ret`.

### 3. Wywoływanie procedury w pętli

Napisać program obliczający sumę elementów tablicy:

```nasm
section .data
    array dq 3, 4, 1, 2, 5

section .bss
    suma resq 1
```

W każdym kroku pętli wywołać procedurę `add_numbers` z zadania 2, przekazując:

- w `rdi` — dotychczasową sumę,
- w `rsi` — wartość bieżącego elementu tablicy.

Wynik zwrócony w `rax` wykorzystać jako sumę w następnej iteracji.

Przed rozpoczęciem pętli przyjąć sumę równą `0`. Po zakończeniu pętli zapisać wynik do zmiennej `suma`.

Wymagania:

1. Przejść po wszystkich elementach tablicy.
2. Wykorzystać instrukcję `loop`.
3. Dodawanie wartości wykonywać w procedurze, a nie bezpośrednio w programie głównym.
4. Do przechowywania adresu bieżącego elementu wykorzystać `rbx`, a jako licznik pętli wykorzystać `rcx`.
5. Zadbać, aby wywoływana procedura nie zmieniała `rbx` ani `rcx`.
6. Sprawdzić wynik w debuggerze.

Oczekiwana wartość zmiennej `suma`: `15`.

Nie trzeba wypisywać wyniku na konsoli.

### 4. Dodawanie dwóch tablic i zapis wyniku do pamięci

Zmodyfikować procedurę z poprzednich zadań tak, aby dodawała dwie tablice element po elemencie i zapisywała wyniki do trzeciej tablicy.

Nową wersję procedury nazwać `add_arrays`.

Przyjąć:

- `rdi` — adres pierwszej tablicy,
- `rsi` — adres drugiej tablicy,
- `rdx` — adres tablicy wynikowej,
- `rcx` — liczba elementów.

Dane:

```nasm
section .data
    array1 dq 3, 4, 1, 2, 5
    array2 dq 1, 2, 3, 4, 5

section .bss
    result_array resq 5
```

Przykładowe wywołanie:

```nasm
    mov rdi, array1
    mov rsi, array2
    mov rdx, result_array
    mov rcx, 5
    call add_arrays
```

Procedura powinna wykonać następujące działanie dla każdego indeksu `i`:

```text
result_array[i] = array1[i] + array2[i]
```

Wymagania:

1. Pętlę umieścić wewnątrz procedury.
2. Adresy tablic i ich długość pobierać z argumentów.
3. Nie odwoływać się wewnątrz procedury bezpośrednio do etykiet konkretnych tablic.
4. Uwzględnić, że każdy element zajmuje 8 bajtów.
5. Wyniki zapisywać bezpośrednio do tablicy wskazywanej przez `rdx`.
6. Dla liczby elementów równej zero zakończyć procedurę bez odczytywania i zapisywania elementów.
7. Sprawdzić tablicę wynikową w debuggerze.

Do odczytywania i dodawania bieżącej pary elementów wystarczy wykorzystać `rax`. Procedura może przesuwać adresy w `rdi`, `rsi` i `rdx` do kolejnych elementów oraz zmniejszać licznik w `rcx`.

Procedura nie musi zwracać wyniku w `rax` — jej wynikiem jest zawartość tablicy w pamięci.

Oczekiwana zawartość tablicy wynikowej:

```text
4, 6, 4, 6, 10
```

## Uwagi

Kod wypisywania z programu początkowego obsługuje tylko pojedynczą cyfrę. Wyniki zadań 3 i 4 należy sprawdzać w debuggerze.

*Last updated: 2026-10-23*
