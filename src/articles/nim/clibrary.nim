const rstText = """
# 【
【ja: Nim言語使用者向けのC言語ライブラリ入門】
【en: C library tutorial for Nimmer】
】

I explained about `GCC`_ and a part of C programming language in `previous article<gccguide.en.html>`_.
I explains about C libraries in this article.

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
  If a large static library or header only library is used by many executables, all of them contains same code and uses much disk space.
- Save memory
  Machine code of functions in shared library loaded in memory can be shared by mutiple processes.

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

.. code-block:: console

  $$ gcc -o usevec3 usevec3.c
  $$ ./usevec3
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

Following example creates static library `libvector3.a` from `vector3.c` and `vector3len.c`.

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

.. code-block:: console

  $$ gcc -c -o vector3.o vector3.c
  $$ gcc -c -o vector3len.o vector3len.c
  $$ ar rcs libvector3.a vector3.o vector3len.o

`ar` is a program included in `GNU binary utilities (GNU Binutils)<https://www.gnu.org/software/binutils/>`_. Static libraries are archives of object files and `ar` can create an archive from object files.

`usevec3.c` uses functions in `libvector3.a`:

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

.. code-block:: console

  $$ gcc -c -o usevec3.o usevec3.c
  $$ gcc -o usevec3 usevec3.o -L. -lvector3 -lm
  $$ ./usevec3
  2.000000
  1.414214

`-l` option links specified library. For example, `-lvector3` searchs directories for `libvector3.a` file.
`-lm` option links the library that provides functions in math.h.
In systems which support shared libraries, ld may also search for files other than `lib*.a`.
On linux, ld searchs for shared library called `lib*.so` before `lib*.a`.
If you have both shared library `libvector3.so` and static library `libvector3.a` but want to link static one, you need to add `-static` option when linking.

`-L` option adds the specified directory to the list of directories that gcc (actually the linker gcc calls that usually ld) will search for libraries. In this case, current directory is added as `libvector3.a` was created in current directory.

See `Options for Linking section in GCC Manual <https://gcc.gnu.org/onlinedocs/>`_ or `ld manual in documentation for binutils <https://www.gnu.org/software/binutils/>`_ for more details.

Work in progress...

.. _GCC: https://gcc.gnu.org
.. _Nim: https://nim-lang.org/

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
