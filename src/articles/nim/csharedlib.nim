const rstText = """
# 【
【ja: Nim言語使用者向けの共有/DLLライブラリ入門】
【en: Shared/Dynamic-link library tutorial for Nimmer】
】

This article explains about Shared/Dynamic-link library.
`Previous article <clibrary.en.html>`_ explains about C libraries.
`This article <gccguide.en.html>`_ explains about `GCC`_ and a part of C programming language.

Work in progress

.. _GCC: https://gcc.gnu.org
.. _Nim: https://nim-lang.org/
.. _Binutils: https://www.gnu.org/software/binutils/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim言語使用者向けの共有/DLLライブラリ入門",
    description:"Nim言語使用者に共有/DLLライブラリの仕組みを説明しNimから正しく使えるようにします。",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Shared/Dynamic-link library tutorial for Nimmer",
    description:"Explains about Shared/Dynamic-link libraries for Nim programmers so that you can use them with Nim",
    category:"Nim"))])
newArticle(articles, rstText)
