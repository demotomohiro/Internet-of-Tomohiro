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
