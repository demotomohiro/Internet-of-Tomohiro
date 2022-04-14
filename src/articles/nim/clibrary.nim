const rstText = """
# 【
【ja: Nim言語使用者向けのC言語ライブラリ入門】
【en: C library tutorial for Nimmer】
】

I explained about `GCC`_ and a part of C programming language in `this <gccguide.en.html>`_ article.
I explains about C libraries in this article.

Before you use C library, you should read the readme or manual of the library and learn how to build and use C libraries.
There are many kind of build tools used for C library.
Some C libraries requires other C libraries and you need to install them before using it.

There are 3 types of C libraries:

- Header only library
- Static library
- Shared/Dynamic-link library

## Header only library

It provides only header files.
You can use it by including header files with `#include`.
You might need to specify a path to the directory that cointains the header files if it is not a part of standard include directory.
All functions are implemented in header files.
Unlike Static link or Dynamic link library, you don't need to build a library before using int.
But content of header files are compiled everytime you compile c files that include them.

## Static library

Static libraries are archives of object files.
You specify static link library at link time and the content of library is added to your executable file or library.
On windows, static libraries have `lib` extension.
On posix, static libraries have a `lib` prefix and `a` extension.
C libraries that provides static or shared library also provides header files that contains type, constant or function declarations.

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
