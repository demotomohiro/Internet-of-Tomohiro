const rstText = """
# 【
【ja: Nim言語使用者向けのC言語ライブラリ入門】
【en: C library tutorial for Nimmer】
】

I explained about `GCC`_ and a part of C programming language in `previous article<gccguide.en.html>`_.
I explains about C libraries in this article.

.. contents::

Before you use C library, you need to read the readme or manual of the library and learn how to build and use C libraries.
There are many kind of build tools used for C library.
Some C libraries requires other C libraries and you also need to install them before using it.

There are package managers that automatically build or download prebuilt libraries and install them.
They can also install dependent libraries automatically.

For example:
- Package managers in Linux distribution like apt, pacman or emerge
- `Conan <https://conan.io>`_
- `MSYS2 <https://www.msys2.org>`_ (Windows only)

There are 3 types of C libraries:

- Header only library
- Static library
- Shared/Dynamic-link library

Static libraries and shared libraries are different kind of files and they are built different ways.

  Actually both static libraries on unix (lib\*.a) and on windows (\*.lib) uses `ar format <https://en.wikipedia.org/wiki/Ar_(Unix)>`_ .
  - https://docs.microsoft.com/en-us/windows/win32/debug/pe-format#archive-library-file-format
  Shared/Dynamic-link libraries are same file format to executable files on most OS.

## Header only library

It provides only header files.
You can use it by including header files with `#include`.
You might need to specify a path to the directory that cointains the header files if it is not a part of standard include directory.
All functions are implemented in header files.
Unlike Static link or Dynamic link library, you don't need to build a library before using it.
But content of header files are compiled everytime you compile c files that include them.

## Static library

Static libraries are archives of object files.
You specify static link library at link time and the content of library is copied into to your executable file or library.

On windows, static libraries have `lib` extension.
(Import library also has `lib` extension on windows)

On posix, static libraries have a `lib` prefix and `a` extension like *libfoo.a*.

C libraries that provides static or shared library also provides header files that contains type, constant or function declarations.

## Shared/Dynamic-link library

Unlike header only libraries or static libraries, a content of shared library is not included in executable files.
Shared libraires are loaded at the programs startup or runtime.

On windows, it is called "Dynamic-link library" or "dll" and has `dll` extension.

On posix, it is called "Shared library" and has `lib` prefix and `so` extension like *libfoo.so*.

On mac, it has `dynlib` extension.

Advantages of Shared libraries:
- You can replace them without recompiling
  - You can update library version and fix bugs quickly
  - Related article: `The modern packager’s security nightmare <https://blogs.gentoo.org/mgorny/2021/02/19/the-modern-packagers-security-nightmare/>`_
- Save disk space
  - If a large static library or header only library is used by many executables, all of them contains same code and uses much disk space.
- Save memory
  - Machine code of functions in shared library loaded in memory can be shared by mutiple processes.

## Example Header only library

Following code shows example header only library `vector3.h` and c file `usevec3.c` that is using it.
`vector3.h` defines `Vector3` type and `vector3Dot` function.

vector3.h:

.. code-block:: c

  #ifndef VECTOR3_H
  #define VECTOR3_H

  typedef struct {
    float x, y, z;
  } Vector3;

  static float vector3Dot(Vector3 v0, Vector3 v1) {
    return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
  }

  #endif

usevec3.c:

.. code-block:: c

  #include <stdio.h>
  #include "vector3.h"

  int main() {
    Vector3 v0 = {-1.0f, 0.0f, 1.0f};
    Vector3 v1 = {0.0f, 1.0f, 2.0f};

    printf("%f\n", vector3Dot(v0, v1));

    return 0;
  }

Compile and run:

On Linux:

.. code-block:: console

  $$ gcc -o usevec3 usevec3.c
  $$ ./usevec3
  2.000000

On Windows:

.. code-block:: console

  >gcc -o usevec3 usevec3.c

  >usevec3
  2.000000

When functions are defined in a header file, it needs to be defined with `static`.
Otherwise, it cause multiple definition errors when the header file is included by multiple `*.c` files.

A function defined with `static` can be used only from the c file where that function is defined and cannot be used from other c files.
So multiple c files can have same name static functions.

For example:

vector3.h:

.. code-block:: c

  #ifndef VECTOR3_H
  #define VECTOR3_H

  typedef struct {
    float x, y, z;
  } Vector3;

  float vector3Dot(Vector3 v0, Vector3 v1) {
    return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
  }

  #endif

foo.h:

.. code-block:: c

  #ifndef FOO_H
  #define FOO_H
  float foo();
  #endif

foo.c:

.. code-block:: c

  #include "foo.h"
  #include "vector3.h"

  float foo(){
    Vector3 v0 = {-1.0f, 1.0f, -2.0f};
    Vector3 v1 = {-1.0f, 1.0f, 2.0f};

    return vector3Dot(v0, v1);
  }

usevec3.c:

.. code-block:: c

  #include <stdio.h>
  #include "vector3.h"
  #include "foo.h"

  int main() {
    Vector3 v0 = {-1.0f, 0.0f, 1.0f};
    Vector3 v1 = {0.0f, 1.0f, 2.0f};

    printf("%f\n", vector3Dot(v0, v1));
    printf("%f\n", foo());

    return 0;
  }

Compile and run:

.. code-block:: console

  $$ gcc -c -o foo.o foo.c
  $$ gcc -c -o usevec3.o usevec3.c
  $$ gcc -o usevec3 usevec3.o foo.o
  ld: foo.o: in function `vector3Dot':
  foo.c:(.text+0x0): multiple definition of `vector3Dot'; usevec3.o:usevec3.c:(.text+0x0): first defined here

If header files in header only library is in a directory different from `*.c` files, or not in default include directory that compiler searches for include files, you need to add `-I` option to specify the directory contains these header files.

## Use header only library from Nim

You can use C header only library from Nim using `header pragma <https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-header-pragma>`_.
It adds `#include "headerfile.h"` in Nim generated C code.
Nim compiler generates C code from input nim code and passes it to backend C compiler. But Nim compiler doesn't read and understand C code.
So Nim needs a code that tells details about struct types and functions in C code so that Nim can generate C code that uses C types and functions correctly and also show error when you call C functions incorrectly.
`c2nim <https://github.com/nim-lang/c2nim>`_, `Futhark <https://github.com/PMunch/futhark>`_ or `Nimterop <https://github.com/nimterop/nimterop>`_ can read a C code and generates nim code that imports C types or functions in the C code.

vector3.h:

.. code-block:: c

  #ifndef VECTOR3_H
  #define VECTOR3_H

  typedef struct {
    float x, y, z;
  } Vector3;

  static float vector3Dot(Vector3 v0, Vector3 v1) {
    return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
  }

  #endif

usevec3.nim:

.. code-block:: nim

  type
    Vector3 {.header: "vector3.h".} = object
      x, y, z: cfloat

  proc vector3Dot(v0, v1: Vector3): cfloat {.header:"vector3.h".}

  let
    v0 = Vector3(x: 1.0, y: 0.0, z: -2.0)
    v1 = Vector3(x: 1.0, y: 0.0, z: 2.0)

  echo vector3Dot(v0, v1)

Compile and run:

.. code-block:: console

  $$ nim c -r usevec3.nim
  Hint: used config file '/etc/nim/nim.cfg' [Conf]
  Hint: used config file '/etc/nim/config.nims' [Conf]
  .........................................................
  CC: stdlib_digitsutils.nim
  CC: stdlib_formatfloat.nim
  CC: stdlib_dollars.nim
  CC: stdlib_io.nim
  CC: stdlib_system.nim
  CC: usevec3.nim
  Hint:  [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  26638 lines; 1.529s; 31.629MiB peakmem; proj: /tmp/tmp/testnim/usevec3.nim; out: /tmp/tmp/testnim/usevec3 [SuccessX]
  Hint: /tmp/tmp/testnim/usevec3  [Exec]
  -3.0

If the header file included with header pragma is not in the same directory to nim file and you got file not found compile error,
specify the path to the directory that contains the header file with `--cincludes` Nim compiler option like `nim c -r --cincludes:/path/to/include/dir usevec3.nim`.

## Example static library

Following example creates static library `libvector3.a` (`vector3.lib` on Windows) from `vector3.c` and `vector3len.c`.

vector3.h:

.. code-block:: c

  #ifndef VECTOR3_H
  #define VECTOR3_H

  // Forward declaration of Vector3
  typedef struct Vector3 Vector3;

  Vector3* createVector3(float x, float y, float z);
  void freeVector3(Vector3* v);

  float vector3Dot(const Vector3* v0, const Vector3* v1);
  float vector3Len(const Vector3* v);

  #endif

vector3.c:

.. code-block:: c

  #include <stdlib.h>
  #include "vector3.h"

  // Members of Vector3 are defined only in this c file.
  struct Vector3 {
    float x, y, z;
  };

  Vector3* createVector3(float x, float y, float z) {
    Vector3* ret = malloc(sizeof(Vector3));
    ret->x = x;
    ret->y = y;
    ret->z = z;

    return ret;
  }

  void freeVector3(Vector3* v) {
    free(v);
  }

  float vector3Dot(const Vector3* v0, const Vector3* v1) {
    return v0->x * v1->x + v0->y * v1->y + v0->z * v1->z;
  }

vector3len.c:

.. code-block:: c

  #include <math.h>
  #include "vector3.h"

  float vector3Len(const Vector3* v) {
    return sqrtf(vector3Dot(v, v));
  }

Following commands compiles `vector3.c` and `vector3len.c` and creates static library `libvector3.a` by linking them:

On Linux:

.. code-block:: console

  $$ gcc -c -o vector3.o vector3.c
  $$ gcc -c -o vector3len.o vector3len.c
  $$ ar rcs libvector3.a vector3.o vector3len.o

On Windows:

.. code-block:: console

  >gcc -c -o vector3.o vector3.c

  >gcc -c -o vector3len.o vector3len.c

  >ar rcs vector3.lib vector3.o vector3len.o

`ar` is a program included in GNU binary utilities (`Binutils`_). Static libraries are archives of object files and `ar` can create an archive from object files.

`usevec3.c` uses functions in `libvector3.a`:

.. _usevec3.c:

usevec3.c:

.. code-block:: c

  #include <stdio.h>
  #include "vector3.h"

  int main() {
    Vector3* v0 = createVector3(-1.0f, 0.0f, 1.0f);
    Vector3* v1 = createVector3(0.0f, 1.0f, 2.0f);

    printf("%f\n", vector3Dot(v0, v1));
    printf("%f\n", vector3Len(v0));

    freeVector3(v1);
    freeVector3(v0);

    return 0;
  }

Following commands compiles `usevec3.c` and creates the executable file by linking `libvector3.a`:

On Linux:

.. code-block:: console

  $$ gcc -c -o usevec3.o usevec3.c
  $$ gcc -o usevec3 usevec3.o -L. -lvector3 -lm
  $$ ./usevec3
  2.000000
  1.414214

On Windows:

.. code-block:: console

  >gcc -c -o usevec3.o usevec3.c

  >gcc -o usevec3 usevec3.o -L. -lvector3 -lm

  >usevec3
  2.000000
  1.414214

`-l` option links specified library. For example, `-lvector3` searchs directories for `libvector3.a` (`vector3.lib` on Windows).
`-lm` option links the library that provides functions in math.h.

The `-l` option is passed directly to the linker by `GCC`_.
In most of systems, ld in GNU `Binutils`_ is called by `GCC`_ in a linking stage to combines object files and libraries to generate an executable or shared library.

In systems which support shared libraries, ld may also search for files other than `lib*.a`.
On linux, ld searchs for shared library called `lib*.so` before `lib*.a`.
If you have both shared library `libvector3.so` and static library `libvector3.a` but want to link static one, you need to add `-static` option when linking.

On Windows, `-lxxx` argument will attempt to find a following library file name in search directories:

| `libxxx.dll.a`
| `xxx.dll.a`
| `libxxx.a`
| `xxx.lib`
| `libxxx.lib`
| `cygxxx.dll`
| `libxxx.dll`
| `xxx.dll`

So you can also use `lib*.a` style file name to static library on windows.

See "direct linking to a dll" in "ld and WIN32 (cygwin/mingw)" in "Machine Dependent Features" section in ld manual in GNU `Binutils`_ for more details.

`-L` option adds the specified directory to the list of directories that ld will search for libraries. In above example command line, current directory is added as `libvector3.a` was created in current directory.

You can also pass a path to the library without `-l` option (but the list of directories for finding libraries is not used):

On Linux:

.. code-block:: console

  $$ gcc -o usevec3 usevec3.o libvector3.a -lm
  $$ ./usevec3
  2.000000
  1.414214

On Windows:

.. code-block:: console

  >gcc -o usevec3 usevec3.o vector3.lib -lm

  >usevec3
  2.000000
  1.414214

See `Options for Linking section in GCC Manual <https://gcc.gnu.org/onlinedocs/>`_ or ld manual in documentation for `Binutils`_ for more details.

An order of object files or libraries can be important.
ld reads object files and libraries in the order they are specified.
If an object file specified after an library contains functions that object file calls, that can cause errors.
Follwing command line just moved `usevec3.o` to the last argument generates link error:

.. code-block:: console

  $$ gcc -o usevec3 -L. libvector3.a -lm usevec3.o
  ld: usevec3.o: in function `main':
  usevec3.c:(.text+0x1f): undefined reference to `createVector3'
  ld: usevec3.c:(.text+0x42): undefined reference to `createVector3'
  ld: usevec3.c:(.text+0x59): undefined reference to `vector3Dot'
  ld: usevec3.c:(.text+0x8b): undefined reference to `vector3Len'
  ld: usevec3.c:(.text+0xbd): undefined reference to `freeVector3'
  ld: usevec3.c:(.text+0xc9): undefined reference to `freeVector3'
  collect2: error: ld returned 1 exit status

When multiple libraries are linked, an order of libraries in argument can also be important.
Following example creates 2 static libraries `libfoo.a` from `foo.c` and `libbar.a` from `bar.c` and `bar.c` calls a function in `foo.c`.
Then `test.c` calls a function in `bar.c`.

foo.h:

.. code-block:: c

  #ifndef FOO_H
  #define FOO_H

  int foo();

  #endif

foo.c:

.. code-block:: c

  #include "foo.h"

  int foo() {
    return 12345;
  }

bar.h:

.. code-block:: c

  #ifndef BAR_H
  #define BAR_H

  int bar();

  #endif

bar.c:

.. code-block:: c

  #include "bar.h"
  #include "foo.h"

  int bar() {
    return foo() * 10 + 6;
  }

test.c:

.. code-block:: c

  #include <stdio.h>
  #include "bar.h"

  int main() {
    printf("%d\n", bar());
  }

Compile them to `libfoo.a`, `libbar.a` and `test`:

.. code-block:: console

  $$ gcc -c -o foo.o foo.c
  $$ ar rcs libfoo.a foo.o
  $$ gcc -c -o bar.o bar.c
  $$ ar rcs libbar.a bar.o
  $$ gcc -c -o test.o test.c
  $$ gcc -o test test.o -L. -lbar -lfoo
  $$ ./test
  123456

But if these libraries were specified in different order, got undefined reference error:

.. code-block:: console

  $$ gcc -o test test.o -L. -lfoo -lbar
  ld: ./libbar.a(bar.o): in function `bar':
  bar.c:(.text+0xa): undefined reference to `foo'

In this case, `-lbar` option need to be placed before `-lfoo` as `libbar.a` calls function in `libfoo.a`.

## Use C static library from Nim

This example nim code calls functions in `vector3.c` and `vector3len.c` in above example by linking `libvector3.a`.

usevec3.nim:

.. code-block:: nim

  type
    Vector3 {.header: "vector3.h".} = object

  proc createVector3(x, y, z: cfloat): ptr Vector3 {.header: "vector3.h".}
  proc freeVector3(v: ptr Vector3) {.header: "vector3.h".}

  proc vector3Dot(v0, v1: ptr Vector3): cfloat {.header: "vector3.h".}
  proc vector3Len(v: ptr Vector3): cfloat {.header: "vector3.h".}

  var
    v0 = createVector3(-1, 0, 1)
    v1 = createVector3(0, 1, 2)

  echo vector3Dot(v0, v1)
  echo vector3Len(v0)

  freeVector3(v0)
  freeVector3(v1)

Compile and run it (Assume `libvector3.a` in same directory to usevec3.nim):

On Linux:

.. code-block:: console

  $$ nim c -r --passL:"-L. -lvector3 -lm" --listcmd usevec3.nim
  Hint: used config file '/etc/nim/nim.cfg' [Conf]
  Hint: used config file '/etc/nim/config.nims' [Conf]
  .........................................................
  CC: stdlib_digitsutils.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/usevec3/stdlib_digitsutils.nim.c
  CC: stdlib_formatfloat.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/stdlib_formatfloat.nim.c.o /tmp/nimcache/d/usevec3/stdlib_formatfloat.nim.c
  CC: stdlib_dollars.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/stdlib_dollars.nim.c.o /tmp/nimcache/d/usevec3/stdlib_dollars.nim.c
  CC: stdlib_io.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/stdlib_io.nim.c.o /tmp/nimcache/d/usevec3/stdlib_io.nim.c
  CC: stdlib_system.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/stdlib_system.nim.c.o /tmp/nimcache/d/usevec3/stdlib_system.nim.c
  CC: usevec3.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/usevec3/@musevec3.nim.c.o /tmp/nimcache/d/usevec3/@musevec3.nim.c
  Hint: x86_64-pc-linux-gnu-gcc   -o /tmp/tmp/testc/usevec3  /tmp/nimcache/d/usevec3/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/usevec3/stdlib_formatfloat.nim.c.o /tmp/nimcache/d/usevec3/stdlib_dollars.nim.c.o /tmp/nimcache/d/usevec3/stdlib_io.nim.c.o /tmp/nimcache/d/usevec3/stdlib_system.nim.c.o /tmp/nimcache/d/usevec3/@musevec3.nim.c.o   -L. -lvector3 -lm  -ldl [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  26645 lines; 1.548s; 31.602MiB peakmem; proj: /tmp/tmp/testc/usevec3.nim; out: /tmp/tmp/testc/usevec3 [SuccessX]
  Hint: /tmp/tmp/testc/usevec3  [Exec]
  2.0
  1.414213538169861

On Windows:

.. code-block:: console

  f:\temp\testc>nim c -r --passL:"-L. -lvector3" --listcmd usevec3.nim
  Hint: used config file 'C:\nim\config\nim.cfg' [Conf]
  Hint: used config file 'C:\nim\config\config.nims' [Conf]
  .........................................................
  CC: stdlib_digitsutils.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\stdlib_digitsutils.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_digitsutils.nim.c
  CC: stdlib_formatfloat.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\stdlib_formatfloat.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_formatfloat.nim.c
  CC: stdlib_dollars.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\stdlib_dollars.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_dollars.nim.c
  CC: stdlib_io.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\stdlib_io.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_io.nim.c
  CC: stdlib_system.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\stdlib_system.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_system.nim.c
  CC: usevec3.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\usevec3\debug\@musevec3.nim.c.o f:\temp\nimcache\usevec3\debug\@musevec3.nim.c
  Hint: gcc.exe   -o f:\temp\testc\usevec3.exe  f:\temp\nimcache\usevec3\debug\stdlib_digitsutils.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_formatfloat.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_dollars.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_io.nim.c.o f:\temp\nimcache\usevec3\debug\stdlib_system.nim.c.o f:\temp\nimcache\usevec3\debug\@musevec3.nim.c.o   -L. -lvector3   [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  26691 lines; 4.416s; 31.559MiB peakmem; proj: f:\temp\testc\usevec3.nim; out: f:\temp\testc\usevec3.exe [SuccessX]
  Hint: f:\temp\testc\usevec3.exe  [Exec]
  2.0
  1.414213538169861

`--listcmd` option is used just for showing how Nim calls GCC.

## Create static library from Nim code and use from C code

Following Nim code implements same functions implemented in `vector3.c` and `vector3len.c`.
They are exported using `exportc pragma<https://nim-lang.org/docs/manual.html#foreign-function-interface-exportc-pragma>`_.

vector3.nim:

.. code-block:: nim

  import math

  type
    Vector3 = object
      x, y, z: cfloat

  proc createVector3*(x, y, z: cfloat): ptr Vector3 {.exportc.} =
    result = create(Vector3)
    result[] = Vector3(x: x, y: y, z: z)

  proc freeVector3*(v: ptr Vector3) {.exportc.} =
    dealloc(v)

  proc vector3Dot*(v0, v1: ptr Vector3): cfloat {.exportc.} =
    v0.x * v1.x + v0.y * v1.y + v0.z * v1.z

  proc vector3Len*(v: ptr Vector3): cfloat {.exportc.} =
    vector3Dot(v, v).sqrt

Following command creates static library `libvector3.a` (`vector3.lib` on Windows) from above Nim code:

On Linux:

.. code-block:: console

  $$ nim c --app:staticlib --noMain:on --listcmd vector3.nim
  Hint: used config file '/etc/nim/nim.cfg' [Conf]
  Hint: used config file '/etc/nim/config.nims' [Conf]
  ..............................................................
  CC: stdlib_digitsutils.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/vector3/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/vector3/stdlib_digitsutils.nim.c
  CC: stdlib_dollars.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/vector3/stdlib_dollars.nim.c.o /tmp/nimcache/d/vector3/stdlib_dollars.nim.c
  CC: stdlib_system.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/vector3/stdlib_system.nim.c.o /tmp/nimcache/d/vector3/stdlib_system.nim.c
  CC: vector3.nim: x86_64-pc-linux-gnu-gcc -c  -w -fmax-errors=3   -I/usr/lib/nim -I/tmp/tmp/testc -o /tmp/nimcache/d/vector3/@mvector3.nim.c.o /tmp/nimcache/d/vector3/@mvector3.nim.c
  Hint: ar rcs /tmp/tmp/testc/libvector3.a  /tmp/nimcache/d/vector3/stdlib_digitsutils.nim.c.o /tmp/nimcache/d/vector3/stdlib_dollars.nim.c.o /tmp/nimcache/d/vector3/stdlib_system.nim.c.o /tmp/nimcache/d/vector3/@mvector3.nim.c.o [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  30761 lines; 1.547s; 31.637MiB peakmem; proj: /tmp/tmp/testc/vector3.nim; out: /tmp/tmp/testc/libvector3.a [SuccessX]

On Windows:

.. code-block:: console

  f:\temp\testc>nim c --app:staticlib --noMain:on --listcmd vector3.nim
  Hint: used config file 'C:\nim\config\nim.cfg' [Conf]
  Hint: used config file 'C:\nim\config\config.nims' [Conf]
  ..............................................................
  CC: stdlib_digitsutils.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\vector3\debug\stdlib_digitsutils.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_digitsutils.nim.c
  CC: stdlib_dollars.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\vector3\debug\stdlib_dollars.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_dollars.nim.c
  CC: stdlib_io.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\vector3\debug\stdlib_io.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_io.nim.c
  CC: stdlib_system.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\vector3\debug\stdlib_system.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_system.nim.c
  CC: vector3.nim: gcc.exe -c  -w -fmax-errors=3 -mno-ms-bitfields   -IC:\nim\lib -If:\temp\testc -o f:\temp\nimcache\vector3\debug\@mvector3.nim.c.o f:\temp\nimcache\vector3\debug\@mvector3.nim.c
  Hint: ar rcs f:\temp\testc\vector3.lib  f:\temp\nimcache\vector3\debug\stdlib_digitsutils.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_dollars.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_io.nim.c.o f:\temp\nimcache\vector3\debug\stdlib_system.nim.c.o f:\temp\nimcache\vector3\debug\@mvector3.nim.c.o [Link]
  Hint: gc: refc; opt: none (DEBUG BUILD, `-d:release` generates faster code)
  30807 lines; 2.771s; 31.672MiB peakmem; proj: f:\temp\testc\vector3.nim; out: f:\temp\testc\vector3.lib [SuccessX]

Without `--noMain:on` option, Nim generates `main` function in C code.
If it is linked with C code containing `main` function, linker generates "multiple definition of main" error.

Link `libvector3.a` created in above command to `usevec3.c`_ in `Example static library`_.

.. code-block:: console

  $$ gcc -c -o usevec3.o usevec3.c
  $$ gcc -o usevec3 usevec3.o -L. -lvector3 -lm
  $$ ./usevec3
  2.000000
  1.414214

.. _GCC: https://gcc.gnu.org
.. _Nim: https://nim-lang.org/
.. _Binutils: https://www.gnu.org/software/binutils/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim言語使用者向けのC言語ライブラリ入門",
    description:"Nim言語使用者にC言語のライブラリの仕組みを説明しNimから正しく使えるようにします。",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"C library tutorial for Nimmer",
    description:"Explains about C library for Nim programmers so that you can use C libraries with Nim",
    category:"Nim"))])
newArticle(articles, rstText)
