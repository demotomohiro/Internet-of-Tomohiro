const rstText = """
# 【
【ja: Nim言語使用者向けのGCCとC言語入門】
【en: GCC and C tutorial for Nimmer】
】

This article explains about `GCC`_ and a part of C programming language for Nimmers trying to uses C libraries with `Nim`_.
There are tools that help importing C libraries to `Nim`_.

- `c2nim <https://github.com/nim-lang/c2nim>`_
- `Futhark <https://github.com/PMunch/futhark>`_
- `Nimterop <https://github.com/nimterop/nimterop>`_

Some knowledge about C and GCC might help you when you use these tools.
How GCC works is related to how Nim uses C libraries because Nim generates C code and calls C compiler to build an executable file.

If you want to learn more about GCC, please read `GCC online documentation <https://gcc.gnu.org/onlinedocs/>`_.

## Hello world

This is hello world code in C:

.. code-block:: c

  #include <stdio.h>

  int main() {
    printf("Hello world\n");

    return 0;
  }

`#include` is an include preprocessor directive in C.
Lines start with `#` are not comments but preprocessor directives and that are processed by preprocessor before compiling.
`stdio.h` is a file name of the header file in C standard library and `#include <stdio.h>` reads the the file and insert the content there.
You need to include `stdio.h` when you use `printf` function.

`int main() { ... }` defines function `main`.
`main` function is the first function called when the program runs.
Unlike Nim or Python, code that are executed at runtime must be written inside functions.
`printf` is a function in C standard library and output text in standard output.

Save above code to file `hello.c`.
Following command compiles it with GCC and produces an executable file `a.out`.

.. code-block:: console

  $$ gcc hello.c
  $$ ./a.out
  Hello world

The executable file name is `a.out` in default. You can specify executable file name with `-o <filename>` option:

.. code-block:: console

  $$ gcc -o hello hello.c
  $$ ./hello
  Hello world

## Define a function

C libraries consist of multiple functions. Lets define a simple C function.

.. code-block:: c

  #include <stdio.h>

  int square(int x) {
    return x * x;
  }

  int main() {
    int sq = square(3);

    printf("3 * 3 = %d\n", sq);

    return 0;
  }

`int square(int x)` is a function that takes 1 int value and return a int value.
Unlike Nim, return type is written before function name and parameter type is written before parameter name.
In `main` function, `square` function is called with int literal 3 and the return value is stored in local variable `sq`.
Unlike Nim, variable type is written before variable name.
Then the value of `sq` is output with `printf` function.
Value of `sq` is converted to string "3" and `%d` in the string literal given to `printf` is relaced with that string.

Compile this code and run:

.. code-block:: console

  $$ gcc -o test test.c
  $$ ./test
  3 * 3 = 9

## Multiple files

Many of C projects are consist of multiple `*.c` files. I separate `square` function to new file `square.c`.

square.c:

.. code-block:: c

  int square(int x) {
    return x * x;
  }

test.c:

.. code-block:: c

  #include <stdio.h>

  int main() {
    int sq = square(3);

    printf("3 * 3 = %d\n", sq);

    return 0;
  }

Unlike Nim, you need to specify all `*.c` files when compiling multiple `*.c` files. 
Compiling them success but shows the warning:

.. code-block:: console

  $$ gcc -o test test.c square.c
  test.c: In function ‘main’:
  test.c:4:12: warning: implicit declaration of function ‘square’ [-Wimplicit-function-declaration]
      4 |   int sq = square(3);
        |            ^~~~~~
  $$ ./test
  3 * 3 = 9

Declaring functions defined in another `*.c` file in the `*.c` files that use them fix the warning:

square.c:

.. code-block:: c

  int square(int x) {
    return x * x;
  }

test.c:

.. code-block:: c

  #include <stdio.h>

  // Declare square to tell types of arguments and return type to the compiler.
  int square(int x);

  int main() {
    int sq = square(3);

    printf("3 * 3 = %d\n", sq);

    return 0;
  }

Then I can compile them without warning:

.. code-block:: console

  $$ gcc -o test test.c square.c
  $$ ./test
  3 * 3 = 9

But why using a function in another `*.c` file without declaring it cause warning?
Because when you call the function with wrong arguments, compiler don't detect it.

For example:

square.c:

.. code-block:: c

  int square(int x) {
    return x * x;
  }

test.c:

.. code-block:: c

  #include <stdio.h>

  int main() {
    // What if you forget to add an argument?
    int sq = square();

    printf("3 * 3 = %d\n", sq);

    return 0;
  }

Then, GCC shows warning but doesn't show compile error.
And the resulting executable file prints wrong output.

.. code-block:: console

  $$ gcc -o test test.c square.c
  test.c: In function ‘main’:
  test.c:6:12: warning: implicit declaration of function ‘square’ [-Wimplicit-function-declaration]
      6 |   int sq = square();
        |            ^~~~~~
  $$ ./test
  3 * 3 = 1

## Define and use struct type

Next example defines a new type `Vector3` and function `vector3Dot` that uses `Vector3` type in `vector.c`.
`testvec3.c` uses `Vector3` variables and calls `vectorDot` function.
`Vector3` is like an object type in Nim with 3 `float32` fields `x, y, z`:

vector3.c:

.. code-block:: c

  typedef struct {
    float x, y, z;
  } Vector3;

  float vector3Dot(Vector3 v0, Vector3 v1) {
    return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
  }

testvec3.c:

.. code-block:: c

  #include <stdio.h>

  float vector3Dot(Vector3 v0, Vector3 v1);

  int main() {
    Vector3 v0 = {-1.0f, 0.0f, 1.0f};
    Vector3 v1 = {0.0f, 1.0f, 2.0f};

    printf("%f\n", vector3Dot(v0, v1));

    return 0;
  }

Compiling them result in error:

.. code-block:: console

  $$ gcc -o testvec3 testvec3.c vector3.c
  testvec3.c:3:18: error: unknown type name ‘Vector3’
      3 | float vector3Dot(Vector3 v0, Vector3 v1);
        |                  ^~~~~~~
  testvec3.c:3:30: error: unknown type name ‘Vector3’
      3 | float vector3Dot(Vector3 v0, Vector3 v1);
        |                              ^~~~~~~

When you use `Vector3` type in other `*.c` files, it also need to be defined in `*.c` files that use it.

testvec3.c:

.. code-block:: c

  #include <stdio.h>

  typedef struct {
    float x, y, z;
  } Vector3;

  float vector3Dot(Vector3 v0, Vector3 v1);

  int main() {
    Vector3 v0 = {-1.0f, 0.0f, 1.0f};
    Vector3 v1 = {0.0f, 1.0f, 2.0f};

    printf("%f\n", vector3Dot(v0, v1));

    return 0;
  }

Now, it compiles and works.

.. code-block:: console

  $$ ./testvec3
  2.000000

## Write and use header file

But when you have many `*.c` files that use these type and function, you have to copying them to all `*.c` files?
In C programming language, header file solves that problem.

vector3.h:

.. code-block:: c

  // This #ifndef ... is a include guard
  #ifndef VECTOR3_H
  #define VECTOR3_H

  typedef struct {
    float x, y, z;
  } Vector3;

  float vector3Dot(Vector3 v0, Vector3 v1);

  #endif

vector3.c:

.. code-block:: c

  #include "vector3.h"

  float vector3Dot(Vector3 v0, Vector3 v1) {
    return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
  }

testvec3.c:

.. code-block:: c

  #include <stdio.h>
  #include "vector3.h"

  int main() {
    Vector3 v0 = {-1.0f, 0.0f, 1.0f};
    Vector3 v1 = {0.0f, 1.0f, 2.0f};

    printf("%f\n", vector3Dot(v0, v1));

    return 0;
  }

`#include "filename.h"` inserts the content of `filename.h` to there.

`#include "filename.h"` is used to include a file with a path relative to a current `*.c` file.
`#include <filename.h>` is used to include a file in standard libraries or system include directories.

.. code-block:: c

  #ifndef VECTOR3_H
  #define VECTOR3_H

  ...

  #endif

Above lines in vector3.h is an include guard that prevents a header file is included multiple times.
If header file X.h and Y.h included file Z.h and foo.c file includes both X.h and Y.h and Z.h didn't have include guard, Z.h is included twice in foo.c.
That causes multiple definitions error.

`#pragma once` is also used as include guard.

Usually you don't need to change GCC command options when you use header file.

.. code-block:: console

  $$ gcc -o testvec3 testvec3.c vector3.c
  $$ ./testvec3
  2.000000

But if a c file includes files in specific directory, you need to add `-I/path/to/include` option:

.. code-block:: console

  $$ gcc -I/path/to/directory -o testvec3 testvec3.c vector3.c

## Compiling c files separately

So far, example codes are compiled with one GCC call, but in most of C projects, GCC is called for each `*.c` files.
If there are many c files, compiling them all take long time.
You would not like to do that everytime you fix a compile error.
You can save your time by calling GCC for each c files and generating an object file.
An `object file <https://en.wikipedia.org/wiki/Object_file>`_ is a machine code output of compiler.
If all c files were successfully compiled to object files, call GCC to link all generated object files and generate an executable file or library.
Then, when you change a line of code in one of c files, you recompile only that c file and link the new object file with existing object files to generate an executable file.
There are tools like 'Makefile' that automatically detect which c files need to be recompiled by comparing time-stamp of a c file and corresponding object file.
If it found a c file need to be recompiled, it automatically calls GCC to compile it and link the new object file with existing object files to generate an executable file or library.

Here, compile each c files manually to learn how it works:

.. code-block:: console

  $$ gcc -c -o vector3.o vector3.c
  $$ gcc -c -o testvec3.o testvec3.c
  $$ gcc -o testvec3 testvec3.o vector3.o
  $$ ./testvec3
  2.000000

`-c` option ask GCC to compile the source files, but do not link. Then GCC generates an object file with file name specified with `-o` option.
Last GCC command links all object files (`testvec3.o` and `vector3.o`) and generates the executable file `testvec3`.
Object files usually have `*.o` extension. MS Visual Studio uses `*.obj` extension for object files.

When compiling simple one line Nim code `echo "Hello"`, Nim calls GCC for each generated c files:

.. code-block:: console

  $$ nim c -r --listcmd hello.nim
  Hint: used config file '/etc/nim/nim.cfg' [Conf]
  Hint: used config file '/etc/nim/config.nims' [Conf]
  .........................................................
  CC: stdlib_digitsutils.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/hello/stdlib_digitsutils.nim.c
  CC: stdlib_dollars.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/stdlib_dollars.nim.c.o /tmp/nimcache/d/hello/stdlib_dollars.nim.c
  CC: stdlib_io.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/stdlib_io.nim.c.o /tmp/nimcache/d/hello/stdlib_io.nim.c
  CC: stdlib_system.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/stdlib_system.nim.c.o /tmp/nimcache/d/hello/stdlib_system.nim.c
  CC: hello.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/@mhello.nim.c.o /tmp/nimcache/d/hello/@mhello.nim.c
  Hint: x86_64-pc-linux-gnu-gcc   -o /tmp/tmp/testc/hello  /tmp/nimcache/d/hello/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/hello/stdlib_dollars.nim.c.o /tmp/nimcache/d/hello/stdlib_io.nim.c.o /tmp/nimcache/d/hello/stdlib_system.nim.c.o /tmp/nimcache/d/hello/@mhello.nim.c.o    -ldl [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  26628 lines; 0.781s; 31.645MiB peakmem; proj: /tmp/tmp/testc/hello.nim; out: /tmp/tmp/testc/hello [SuccessX]
  Hint: /tmp/tmp/testc/hello  [Exec]
  Hello

Above `--listcmd` option shows GCC commands Nim calls to compile c files. `x86_64-pc-linux-gnu-gcc` in above output is my GCC executable name.
Nim implicitly imports system module and system module imports other modules (digitsutils, dollars, io). Each modules are compiled by Nim to generate c files and each generated c files are compiled by GCC to generate object files.

If you want to know GCC option in above output: 
- `-w`
  - Inhibit all warning messages. Warning messages are important if you manually write C code but less important when compiling generated C code.

- `-fmax-errors=n`
  - Limits the maximum number of error messages to n, Nim checks errors in input Nim code and you don't get error message from backend C compiler as long as you don't encounter Nim's bugs or you use FFI pragma incorrectly. C compiler can output large number of error messages but errors can be fixed by reading only first 2 or 3 error messages..

Then I changed `echo "Hello"` to `echo "Hello Nim!"`:

.. code-block:: console

  $$ nim c -r --listcmd hello.nim
  Hint: used config file '/etc/nim/nim.cfg' [Conf]
  Hint: used config file '/etc/nim/config.nims' [Conf]
  .........................................................
  CC: hello.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3 -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/hello/@mhello.nim.c.o /tmp/nimcache/d/hello/@mhello.nim.c
  Hint: x86_64-pc-linux-gnu-gcc -o /tmp/tmp/testc/hello /tmp/nimcache/d/hello/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/hello/stdlib_dollars.nim.c.o /tmp/nimcache/d/hello/stdlib_io.nim.c.o /tmp/nimcache/d/hello/stdlib_system.nim.c.o /tmp/nimcache/d/hello/@mhello.nim.c.o -ldl [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  26628 lines; 0.374s; 31.598MiB peakmem; proj: /tmp/tmp/testc/hello.nim; out: /tmp/tmp/testc/hello [SuccessX]
  Hint: /tmp/tmp/testc/hello  [Exec]
  Hello Nim!

This time, c files corresponding to system module and stdlib are not compiled by GCC again, only `@mhello.nim.c` was compiled.



.. _GCC: https://gcc.gnu.org
.. _Nim: https://nim-lang.org/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim使用者向けのGCCとC言語入門",
    description:"Nimに関するよくある質問と答え",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"GCC and C tutorial for Nimmer",
    description:"Explains about GCC and C programming language for Nim programmers so that you can understand how Nim uses C libraries",
    category:"Nim"))])
newArticle(articles, rstText)
