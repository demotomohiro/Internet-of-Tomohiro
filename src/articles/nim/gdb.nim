const rstText = """
【
【ja:NimをGDBでデバッグする】
【en:Debug Nim with GDB】
】
======

【
【ja:`GDB`_ はコマンドライン上でプログラムをデバッグするツールです。
GDBを使えばプログラムを実行中に特定の箇所で停止して変数の値を見たり一行づつプログラムを実行することなどができます。
】
【en:`GDB`_ is a command line debug tool.
You can stop your program at specified point and print a value of variable or run it line by line.
】
】

【
【ja:GDBをインストールする】
【en:Install GDB】
】
-----
【
【ja:GDBがインストールされているかどうかは以下のコマンドで確認できます。
】
【en:You can check if GDB is installed on your PC with following command.
】
】
- Linux:
.. code-block::

   which gdb

- Windows:
.. code-block::

   where gdb

【
【ja:もしインストールされていなければパッケージマネージャ(apt, pacman, emergeなど)を使ってインストールしてください。
Windowsでは `Scoop`_ というパッケージマネージャを使うと ``scoop install gdb`` でインストールできます。
`Scoop`_ を使いたくなければ `TDM-GCC`_ からダウンロードして下さい。
】
【en:If GDB is not installed on your PC, install it using your package manager (apt, pacman, emerge, etc).
If you use package manager `Scoop`_ on Windows, you can install it with ``scoop install gdb``.
Or you can download it from `TDM-GCC`_.
】
】

【
【ja:GDBでデバッグできるようにコンパイルする】
【en:Compile your program so that you can debug it with GDB】
】
-----

【
【ja:GDBでデバッグするには以下のように ``--debugger:native`` オプションをつけてコンパイルします。
】
【en:You need to add ``--debugger:native`` option when you compile your program like following example command so that you can debug your program with GDB.
】
】

.. code-block::

   nim c --debugger:native test.nim

【
【ja:GDBで簡単なプログラムをデバッグしてみる】
【en:Debug simple program with GDB】
】
-----

【
【ja:
】
【en:
】
】

.. _GDB: https://www.gnu.org/software/gdb/
.. _Scoop: https://scoop.sh/
.. _TDM-GCC _http://tdm-gcc.tdragon.net/
"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"NimをGDBでデバッグする",
    description:"Nim言語で書いたプログラムをGDBでデバッグする方法を紹介します")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Debug Nim with GDB",
    description:"How to use GDB to debug a program written with Nim language"))])
newArticle(articles, rstText)
