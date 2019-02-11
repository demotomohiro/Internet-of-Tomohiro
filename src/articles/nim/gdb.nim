const rstText = """
【
【ja:NimをGDBでデバッグする】
【en:Debug Nim with GDB】
】
======

【
【ja:`GDB`_ はコマンドライン上でプログラムをデバッグするツールです。
GDBを使えばプログラムを実行中に特定の箇所で停止して変数の値を見たり一行づつプログラムを実行することなどができます。
GDBについて詳しく知りたい方は `GDB User Manual`_ を参照して下さい。
】
【en:`GDB`_ is a command line debug tool.
You can stop your program at specified point and print a value of variable or run it line by line.
If you want to learn more about GDB, check `GDB User Manual`_.
】
】

- `【
【ja:Nim公式のGDBの使い方を説明したYoutube動画もあります。】
【en:There is official Nim GDB Youtube Video.】
】 <https://www.youtube.com/watch?v=DmYOPkI_LzU>`_

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

On Linux:

.. code::

   which gdb

On Windows:

.. code::

   where gdb

【
【ja:もしインストールされていなければパッケージマネージャ(apt, pacman, emergeなど)を使ってインストールしてください。
GDBはMinGWに含まれています。
Windowsで `Scoop`_ というパッケージマネージャを使う場合、``scoop install gcc`` でgccをインストールするとGDBも一緒にインストールされます。``scoop install gdb`` でGDBだけをインストールできますが、gccに付属するGDBよりも古いです。
`Scoop`_ を使いたくなければ `TDM-GCC`_ からダウンロードできます。
】
【en:If GDB is not installed on your PC, install it using your package manager (apt, pacman, emerge, etc).
GDB is included in MinGW.
If you use package manager `Scoop`_ on Windows, GDB is installed when you install gcc with ``scoop install gcc``.
You can also install it alone with ``scoop install gdb`` command, but it is older than the GDB included in gcc.
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

.. code::

   nim c --debugger:native test.nim

【
【ja:GDBで簡単なプログラムをデバッグしてみる】
【en:Debug simple program with GDB】
】
-----

【
【ja:以下のコードを ``test.nim`` に保存しGDBでデバッグしてみます。
】
【en:Let's debug following code with GDB. Save it as filename ``test.nim``.
】
】

.. code-block::
  type
    TestObj = object
      num: int
      val: float
      str: string

  proc initTestObj(num: int): TestObj =
    TestObj(num: num, val: 3.141, str: "TestObj")

  proc foo(x: int): int =
    let y = x + 2
    return y * 10

  proc bar(x: int): int =
    if x == 3:
      return foo(x)
    return x * 100

  proc main =
    var a = 1
    a += 3
    let str = "foobar"
    var seq1 = @[0, 1, 2, 3, 4]
    a = bar(1)
    a = bar(2)
    a = bar(3)
    let tobj = initTestObj(11)

  main()

【
【ja:このコードを ``--debugger:native`` をつけてコンパイルした後に ``nim-gdb`` に読み込ませます。
】
【en:Compile this code with ``--debugger:native`` and load it to ``nim-gdb``.
】
】

.. code::

   nim c --debugger:native test.nim
   nim-gdb test

【
【ja:もしnim-gdbが無い場合は `Nim repository`_ から ``Nim/bin/nim-gdb`` と ``Nim/tools/nim-gdb.py`` をダウンロードして下さい。
nim-gdbを使わない場合はGDBを起動した後に ``source Nim/tools/nim-gdb.py`` を実行して下さい。
nim-gdbはGDBを実行し ``Nim/tools/nim-gdb.py`` を読み込ませるbashスクリプトです。
nim-gdb.pyはNimの変数がGDBで綺麗に表示されるようにするためのPythonスクリプトです。
】
【en:If you cannot find nim-gdb, you can download ``Nim/bin/nim-gdb`` and ``Nim/tools/nim-gdb.py`` from `Nim repository`_.
If you don't use nim-gdb, execute ``source Nim/tools/nim-gdb.py`` command after you run gdb.
nim-gdb is a bash script that execute GDB and let GDB load ``Nim/tools/nim-gdb.py``.
And nim-gdb.py is a Python script that make GDB print Nim variables nicely.
】
】

【
【ja:nim-gdbはbashスクリプトなのでWindowsではbash等をインストールしないとそのまま使えません。
なので以下のようにして ``tools\nim-gdb.py`` をGDBに読み込む必要があります。
GDB起動後に
】
【en:On Windows, nim-gdb is a bash script and you cannot use it without bash.
So you need to load ``tools\nim-gdb.py`` using ``source`` command.
Please run following command on GDB:
】
】

.. code::

  source {path-to-nim}\tools\nim-gdb.py

【
【ja:を実行するか以下のようにGDBを起動して下さい。
】
【en:Or execute GDB like this:
】
】

.. code::

  gdb -eval-command "source {path-to-nim}\tools\nim-gdb.py" test

【
【ja:nim-gdbが実行されると以下のようなメッセージが表示されます。
実行ファイルにデバッグに必要な情報が含まれていれば ``Reading symbols from test...done.`` と表示されるはずです。
もし ``--debugger:native`` オプションをつけ忘れてコンパイルすると ``Reading symbols from test...(no debugging symbols found)...done`` と表示されます。
】
【en:Following message will be displayed after run nim-gdb.
If a executable file contains information that help debuging, GDB prints ``Reading symbols from test...done``.
If you compiled a code without ``--debugger:native`` options, it will print ``Reading symbols from test...(no debugging symbols found)...done``.
】
】

.. code::

  GNU gdb (Gentoo 8.1 p1) 8.1
  Copyright (C) 2018 Free Software Foundation, Inc.
  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
  This is free software: you are free to change and redistribute it.
  There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
  and "show warranty" for details.
  This GDB was configured as "x86_64-pc-linux-gnu".
  Type "show configuration" for configuration details.
  For bug reporting instructions, please see:
  <https://bugs.gentoo.org/>.
  Find the GDB manual and other documentation resources online at:
  <http://www.gnu.org/software/gdb/documentation/>.
  For help, type "help".
  Type "apropos word" to search for commands related to "word"...
  Reading symbols from test...done.
  (gdb)

【
【ja:``quit`` または ``q`` コマンドを実行するか ``Ctrl-d`` キーを押すとGDBを終了できます。】
【en:You can quit GDB with the ``quit`` or ``q`` command or Ctrl-d key.】
】


【
【ja:まずbreak pointを設定してみます。コードの中にブレークポイントを設定することによって、プログラムが実行中にその場所に到達すると一時停止させることができます。
``b`` または ``break`` コマンドにプロシージャ名を与えることによってそのプロシージャが始まる場所にbreak pointを設定できます。
GDBではNimで書いたプロシージャの名前を直接指定することができず、プロシージャ名にハッシュ値が付いた名前で指定する必要があります。
例えば、``foo`` という名前のプロシージャにbreak pointを設定するときは ``break foo_`` と入力した後にtabキーを入力するとプロシージャ名についたハッシュ値が補完されます。
】
【en:let's set a break point. If you set a break point inside souce code, the program will pause when it reached to that point.
You can make a break point by executing ``b`` or ``break`` command with procedure name.
But you cannot specify a procedure name as is to ``break`` command.
You have to specify a procedure name with hash value.
For example, when you make a break point to procedure ``foo``, Type ``break foo_`` and push a tab key.
Then, hash value added to that procedure name will be complemented.
】
】

.. code::

  (gdb) break foo_yBfYXi2FBVfUOybMAWEXjA_2
  Breakpoint 1 at 0x10544: file /tmp/tmp/test.nim, line 10.

【
【ja:ファイル名と行番号を指定してbreak pointを設定することもできます。
】
【en:You can also make a break point with filename and line number.
】
】

.. code::

  (gdb) break test.nim:21
  Breakpoint 2 at 0x1088a: file /tmp/tmp/test.nim, line 21.

【
【ja:``run`` コマンドでプログラムを実行します。
先程設定したtest.nimの21行目のbreak pointでプログラムが停止します。
なので ``a += 3`` が実行される直前で停止します。
】
【en:``run`` command start your program under GDB.
Then, the program stop at the break point in line 21 of test.nim.
It stops right before the ``a += 3`` is executed.
】
】

.. code::

  Starting program: /tmp/tmp/test

  Breakpoint 2, main_Ak9bvQf5hr5bnkcYq9cDinOw ()
      at /tmp/tmp/test.nim:21
  21        a += 3

【
【ja:``print`` または ``p`` コマンドで変数の中身を見ることができます。
】
【en:You can see the value of an variable using ``print`` or ``p`` command.
】
】

.. code::

  (gdb) print a
  $$1 = 1

【
【ja:``next`` または ``n`` コマンドで一行だけ実行します。
このときに ``a += 3`` が実行されます。
】
【en:You can execute only 1 line with ``next`` or ``n`` command.
Then, ``a += 3`` is executed.
】
】

.. code::

  (gdb) next
  22        let str = "foobar"
  (gdb) print a
  $$2 = 4

【
【ja:``next`` コマンドに実行したい行数を指定することができます。
】
【en:You can specify a number of lines to execute to ``next`` command.
】
】

.. code::

  (gdb) next 3
  25        a = bar(2)
  (gdb) print a
  $$3 = 100

【
【ja:``step`` または ``s`` コマンドで次の行で呼ばれるプロシージャの中に入ることができます。
】
【en:You can enter a procedure that will be called in next line with ``step`` or ``s`` command.
】
】

.. code::

  (gdb) step
  bar_yBfYXi2FBVfUOybMAWEXjA (x=2) at /tmp/tmp/test.nim:14
  14      proc bar(x: int): int =

【
【ja:``finish`` または ``fin`` コマンドで今いるプロシージャから抜けるまでプログラムを実行します。
】
【en:``finish`` or ``fin`` command run the program until it exits currently executing procedure.
】
】

.. code::

  (gdb) finish
  Run till exit from #0  bar_yBfYXi2FBVfUOybMAWEXjA (x=2)
      at /tmp/tmp/test.nim:14
  0x000055555556494b in main_Ak9bvQf5hr5bnkcYq9cDinOw ()
      at /tmp/tmp/test.nim:25
  25        a = bar(2)
  Value returned is $$4 = 200
  (gdb) next
  26        a = bar(3)
  (gdb) print a
  $$5 = 200

【
【ja:``continue`` または ``c`` コマンドでプログラムが終了するかbreakpointに引っかかるまで実行されます。
】
【en:``continue`` or ``c`` command resume program execution util the program ends or it reach to a breakpoint.
】
】

.. code::
  (gdb) continue
  Continuing.

  Breakpoint 1, foo_yBfYXi2FBVfUOybMAWEXjA_2 (x=3)
      at /tmp/tmp/test.nim:10
  10      proc foo(x: int): int =

【
【ja:``backtrace`` または ``bt`` コマンドでbacktraceを表示します。
``main`` プロシージャの26行目から ``bar(3)`` プロシージャが呼ばれ、``bar`` プロシージャの16行目から ``foo(3)`` プロシージャが呼ばれているのがわかります。
】
【en:``backtrace`` or ``bt`` command display a backtrace.
You can see ``bar(3)`` procedure was called from ``main`` procedure at line 26, and ``foo(3)`` procedure was called from ``bar`` procedure at line 16.
】
】

.. code::

  (gdb) backtrace
  #0  foo_yBfYXi2FBVfUOybMAWEXjA_2 (x=3) at /tmp/tmp/test.nim:10
  #1  0x0000555555564697 in bar_yBfYXi2FBVfUOybMAWEXjA (x=3)
      at /tmp/tmp/test.nim:16
  #2  0x000055555556496c in main_Ak9bvQf5hr5bnkcYq9cDinOw ()
      at /tmp/tmp/test.nim:26
  #3  0x0000555555564b38 in NimMainModule ()
      at /tmp/tmp/test.nim:29
  #4  0x0000555555564a46 in NimMainInner ()
      at /tmp/tmp/Nim/lib/system.nim:3154
  #5  0x0000555555564a82 in NimMain ()
      at /tmp/tmp/Nim/lib/system.nim:3162
  #6  0x0000555555564ad0 in main (argc=1, args=0x7fffffffde58,
      env=0x7fffffffde68) at /tmp/tmp/Nim/lib/system.nim:3169

【
【ja:``list`` または ``l`` コマンドで現在いる場所付近のソースコードを表示します。
】
【en:``list`` or ``l`` command print lines from source code.
】
】

.. code::

  (gdb) list
  5           str: string
  6
  7       proc initTestObj(num: int): TestObj =
  8         TestObj(num: num, val: 3.141, str: "TestObj")
  9
  10      proc foo(x: int): int =
  11        let y = x + 2
  12        return y * 10
  13
  14      proc bar(x: int): int =

【
【ja:``info breakpoints`` または ``info break`` コマンドでbreak pointのリストを表示します。
】
【en:``info breakpoints`` or ``info break`` command prints a table of all breakpoints.
】
】

.. code::
  (gdb) info breakpoints
  Num     Type           Disp Enb Address            What
  1       breakpoint     keep y   0x0000555555564544 in foo_yBfYXi2FBVfUOybMAWEXjA_2 at /tmp/tmp/test.nim:10
          breakpoint already hit 1 time
  2       breakpoint     keep y   0x000055555556488a in main_Ak9bvQf5hr5bnkcYq9cDinOw at /tmp/tmp/test.nim:21
          breakpoint already hit 1 time

【
【ja:ここに表示されている番号を ``delete`` または ``d`` コマンドに指定することによってbreakpointを削除することができます。
】
【en:You can delete a breakpoint by specifying a number on above list to ``delete`` or ``d`` command.
】
】

.. code::

  (gdb) delete 2
  (gdb) info breakpoints
  Num     Type           Disp Enb Address            What
  1       breakpoint     keep y   0x0000555555564544 in foo_yBfYXi2FBVfUOybMAWEXjA_2 at /tmp/tmp/test.nim:10
          breakpoint already hit 1 time

【
【ja:``info locals`` コマンドで現在いるプロシージャの全ローカル変数を表示することができます。
】
【en:``info locals`` command prints all local variables of a procedure.
】
】

.. code::

  (gdb) next
  11        let y = x + 2
  (gdb) next
  12        return y * 10
  (gdb) info locals
  result = 0
  y = 5
  TM_ipcYmBC9bj9a1BW35ABoB1Kw_6 = 5
  TM_ipcYmBC9bj9a1BW35ABoB1Kw_7 = 93824992304216
  FR_ = {prev = 0x7fffffffdc20,
    procname = 0x555555565d58 "foo", line = 11,
    filename = 0x555555565d5c "test.nim", len = 0,
    calldepth = 3}
  (gdb) finish
  Run till exit from #0  foo_yBfYXi2FBVfUOybMAWEXjA_2 (x=3)
      at /tmp/tmp/test.nim:12
  0x0000555555564697 in bar_yBfYXi2FBVfUOybMAWEXjA (x=3)
      at /tmp/tmp/test.nim:16
  16          return foo(x)
  Value returned is $$2 = 50
  (gdb) finish
  Run till exit from #0  0x0000555555564697 in bar_yBfYXi2FBVfUOy
  bMAWEXjA (x=3) at /tmp/tmp/test.nim:16
  0x000055555556496c in main_Ak9bvQf5hr5bnkcYq9cDinOw ()
      at /tmp/tmp/test.nim:26
  26        a = bar(3)
  Value returned is $$3 = 50
  (gdb) next
  27        let tobj = initTestObj(11)
  (gdb) next
  28
  (gdb) info locals
  a = 50
  TM_ipcYmBC9bj9a1BW35ABoB1Kw_2 = 4
  str = "foobar"
  seq1 = seq(5, 5) = {0, 1, 2, 3, 4}
  tobj = {num = 11, val = 3.141, str = "TestObj"}
  FR_ = {prev = 0x7fffffffdce0,
    procname = 0x555555565d75 "main", line = 27,
    filename = 0x555555565d5c "test.nim", len = 0,
    calldepth = 1}

GDB Text User Interface
-----
【
【ja:(Windowsでは使えないっぽい)

GDBでText User Interface(TUI) modeにすると画面を分割してソースコード、アセンブリ言語、レジスタの値を表示できるようになります。
``tui enable`` コマンドでTUI modeになり、 ``tui disable`` で元のモードに戻ります。
Ctrl-aキーを押した後にaキーを押すことでもTUI modeを切り替えられます。
GDB起動時に ``-tui`` オプションを指定するとTUI modeがデフォルトになります。

画面が乱れたときは ``Ctrl + L`` キーで画面をリフレッシュできます。
】
【en:
(This mode is not available on windows?)

In GDB Text User Interface(TUI) mode, screen is split and it can show source code, assembly, or regisers.
You can enable TUI mode with ``tui enable`` command, and disable with ``tui disable``.
You can also change mode by pushing a key after Ctrl-a key.
TUI mode is enabled by default by adding ``-tui`` option when you execute GDB command.

If the screen messed up, you can refresh it with ``Ctrl + L`` key.
】
】



【
【ja:GDBで簡単なプログラムをデバッグしてみる2】
【en:Debug other simple program with GDB】
】
-----

【
【ja:以下のコードを ``test2.nim`` に保存しGDBでデバッグしてみます。
】
【en:Let's debug following code with GDB. Save it as filename ``test2.nim``.
】
】

.. code::

  import os, strutils

  proc main =
    let params = commandLineParams()
    if params.len == 0:
      return

    let count = parseInt(params[0])

    var x = 0
    var sum = 0
    for i in 0..count:
      inc sum
      if sum == 10:
        inc x

    echo sum

  main()

【
【ja:デバッグするプログラムに引数を与えるときはnim-gdbを起動するときに ``--args`` を指定し実行ファイル名の後に引数を指定します。
】
【en:You can specify the arguments to your program by adding ``--args`` option to nim-gdb and append the arguments after the program filenae.
】
】

.. code::

  nim-gdb --args test2 1000 foo
  (gdb) break test2.nim:11
  Breakpoint 1 at 0x11b35: file /tmp/tmp/test2.nim, line 11.
  (gdb) run
  Starting program: /tmp/tmp/test2 1000 foo
  [Thread debugging using libthread_db enabled]
  Using host libthread_db library "/lib64/libthread_db.so.1".

  Breakpoint 1, main_3iLAKFrCD49cjgkzKbLZt2A () at /tmp/tmp/test2.nim:11
  11        var sum = 0
  (gdb) print params
  $$1 = seq(2, 2) = {"1000", "foo"}

【
【ja:``run`` コマンドに引数を指定することもできます。
】
【en:You can also specify the arguments to your program to ``run`` command.
】
】

.. code::

  nim-gdb test2
  (gdb) break test2.nim:11
  Breakpoint 1 at 0x11b35: file /tmp/tmp/test2.nim, line 11.
  (gdb) run 1000 foo
  Starting program: /tmp/tmp/test2 1000 foo
  [Thread debugging using libthread_db enabled]
  Using host libthread_db library "/lib64/libthread_db.so.1".

  Breakpoint 1, main_3iLAKFrCD49cjgkzKbLZt2A () at /tmp/tmp/test2.nim:11
  11        var sum = 0
  (gdb) print params
  $$1 = seq(2, 2) = {"1000", "foo"}

【
【ja:Watchpointを使うことによって指定した変数の値が変化したときにプログラムを停止させることができます。
】
【en:Watchpoint stop your program whenever the value of the specified variable changed.
】
】

.. code::

  (gdb) watch x
  Hardware watchpoint 2: x
  (gdb) continue
  Continuing.

  Hardware watchpoint 2: x

  Old value = 0
  New value = 1
  0x0000555555565c3b in main_3iLAKFrCD49cjgkzKbLZt2A () at /tmp/tmp/test2.nim:15
  15            inc x
  (gdb) print sum
  $$1 = 10
  (gdb) print x
  $$2 = 1

【
【ja:``print`` コマンドで変数の値を変更することができます。
】
【en:You can change the value of the specified variable using ``print`` command.
】
】

.. code::

  (gdb) print sum = 0
  $$3 = 0
  (gdb) print sum
  $$4 = 0
  (gdb) continue
  Continuing.

  Hardware watchpoint 2: x

  Old value = 1
  New value = 2
  0x0000555555565c3b in main_3iLAKFrCD49cjgkzKbLZt2A () at /tmp/tmp/test2.nim:15
  15            inc x
  (gdb) print sum
  $$5 = 10
  (gdb) print x
  $$6 = 2

【
【ja:``until`` または ``u`` コマンドで一行だけ実行することができますが、ループがある場合はループが終わるまで実行されます。
】
【en:You can execute only 1 line with ``until`` or ``u`` command and it can be used to exit loop.
】
】

.. code::

  (gdb) until
  2166            inc(res)
  (gdb) until
  2164          while res <= int(b):
  (gdb) until
  17        echo sum

【
【ja:NimコンパイラをGDBでデバッグ】
【en:Debug Nim compiler with GDB】
】
-----

【
【ja:NimコンパイラはNim言語で書かれNimコンパイラでコンパイルされます。なのでnim-gdbでデバッグできます。
まずは普通にNim compilerをビルドします。
】
【en:Nim compiler is written with Nim language and compiled with Nim compiler. So you can debug it with nim-gdb.
At first, compile Nim as written on readme.md.
】
】

.. code::

  git clone https://github.com/nim-lang/Nim.git
  cd Nim

On linux:

.. code::

  sh build_all.sh

On windows:

.. code::

  git clone --depth 1 https://github.com/nim-lang/csources.git
  cd csources
  build64.bat
  cd ..

  bin\nim c koch
  koch boot -d:release
  koch tools # Compile Nimble and other tools

【
【ja:Nimコンパイラをデバッグ用にコンパイルします。
``bin`` ディレクトリに ``nim_temp`` が出力されます。
】
【en:Compile Nim compiler for debug.
``nim_temp`` will be created in ``bin`` directory.
】
】

.. code::

  koch temp


【
【ja:``nim_temp`` をデバッグします。
】
【en:Debug ``nim_temp``.
】
】

.. code::

  nim-gdb --args bin/nim_temp c ../test.nim

【
【ja:他のGDBの便利な機能】
【en:Other useful GDB commands】
】
-----
* ``skip``

  【
  【ja:このコマンドを使うと ``step`` コマンドを使ったときなどに指定したプロシージャに入らないようにできます。
  ``-file`` や ``-gfile`` オプションでソースコードを指定するとそこで定義されているすべてのプロシージャがスキップされるようになります。
  例えば以下のコマンドで ``system`` モジュールにあるプロシージャがスキップされるようになります。
  】
  【en:You can use this command so that ``step`` command don't step into specified procedure.
  With ``-file`` or ``-gfile`` option, all procedures defined in specified source code will be skipped.
  For example, all procedures in ``system`` module will be skipped with following commands.
  】
  】

  .. code::

    skip -gfile lib/system.nim
    skip -gfile lib/system/*.nim

  `【
  【ja:skipコマンドの詳細】
  【en:More info about skip command】
  】 <https://sourceware.org/gdb/current/onlinedocs/gdb/Skipping-Over-Functions-and-Files.html>`_

* ``rbreak`` *regex*

  【
  【ja:このコマンドを使うと正規表現 *regex* に名前がマッチするすべてのプロシージャにbreakpointを設定します。
  】
  【en:Set breakpoints on all procedures matching the regular expression *regex*.
  】
  】

  `【
  【ja:rbreakコマンドの詳細】
  【en:More info about rbreak command】
  】 <https://sourceware.org/gdb/current/onlinedocs/gdb/Set-Breaks.html#index-breakpoints-at-functions-matching-a-regexp>`_

* ``save breakpoints`` *filename*

  【
  【ja:設定されているすべてのbreakpointを *filename* に保存します。
  後で ``source`` コマンドを使って 読み込むことができます。
  】
  【en:Saves all current breakpoint definitions to *filename*.
  Use the ``source`` command to read the saved breakpoints.
  】
  】

  `【
  【ja:save breakpointsコマンドの詳細】
  【en:More info about save breakpoints】
  】 <https://sourceware.org/gdb/current/onlinedocs/gdb/Save-Breakpoints.html#Save-Breakpoints>`_

.. _GDB: https://www.gnu.org/software/gdb/
.. _GDB User Manual: https://sourceware.org/gdb/current/onlinedocs/gdb/
.. _Scoop: https://scoop.sh/
.. _TDM-GCC: http://tdm-gcc.tdragon.net/
.. _Nim repository: https://github.com/nim-lang/nim
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
