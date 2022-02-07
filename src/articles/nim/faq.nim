import std/[strutils, strformat]

# Add indent with replace
const nimVerOutput = staticExec("nim -v").replace("\n", "\n  ")

const rstText = &"""
# 【
【ja: Nimに関するよくある質問と答え】
【en: Frequently Asked Questions about Nim programming language】
】

This is a FAQ about `Nim`_ programming language.
If you have a question about Nim, please ask it in `Nim forum <https://forum.nim-lang.org>`_.

`Another FAQ <https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ>`_

.. contents::

## Language design

### What is Zen of Nim?

- https://nim-lang.org/blog/2021/11/15/zen-of-nim.html
- https://forum.nim-lang.org/t/8630

### Why Nim use style insensivity?

- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-is-it-caseunderscore-insensitive
- https://forum.nim-lang.org/t/8497

### Why Nim use space for indent instead of tab?

- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-are-tabs-forbidden

### Why Nim use garbage collecter?

### Why Nim transepile to C?

- C language is supported in many platform
- A lot of effort has been spent for long time to generate optimized executable file. Nim can use that optimizer to generate fast code
- There are a lot of mature C libraries. Nim can easily use it

### Is Nim a Transpiler?

- https://peterme.net/is-nim-a-transpiler.html
- https://forum.nim-lang.org/t/8520

### Why are unsigned types discouraged?

- In default, Nim checks over/under flow to signed int but unsigned int
- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-are-unsigned-types-discouraged
- https://forum.nim-lang.org/t/8737

### Why doesn't default import statement force fully qualify access to the imported symbols?

- https://narimiran.github.io/2019/07/01/nim-import.html

## Coding

### How to make nested tables?

- https://forum.nim-lang.org/t/8568

### How to get Nim version?

On console, run `nim -v`.

Example output:

.. code-block:: console

  $$ nim -v
  {nimVerOutput}

In Nim code, you can use `NimVersion` const string or `NimMajor`, `NimMinor` and `NimPatch` const int in system module.

.. code-block:: nim

  echo NimVersion
  echo (NimMajor, NimMinor, NimPatch)

### How to skip writing import

- https://forum.nim-lang.org/t/8591

### How to pass iterator to procedure?

- https://nim-lang.org/docs/manual.html#iterators-and-the-for-statement-firstminusclass-iterators
- https://nim-lang.org/docs/manual.html#overload-resolution-iterable

### Can Nim create class method?

.. code-block:: nim

  type
    Foo = object
      x: int

  proc myClassMethod(f: typedesc[Foo]; param: int): Foo =
    Foo(x: param)

  let foo = myClassMethod(Foo, 123)
  echo foo

### sizeof(ref object/seq/string) returns incorrect size

`ref object`, `seq` and `string` are actually pointer to the heap memory that contains the content.
So using `sizeof` to these type returns size of pointer.
You can get size of the content using `len` proc to seq/string.

.. code-block:: nim

  import std/sugar

  type
    Foo = ref object
      x: array[123, int]

  dump sizeof(Foo)
  dump sizeof(Foo()[])
  let f = new Foo
  dump sizeof(f)
  dump sizeof(f[])

  dump sizeof(@[1, 2, 3])
  let s = @[1, 2, 3]
  dump sizeof(s[0]) * s.len

  dump sizeof("foo")
  let str = "foo"
  dump sizeof(str)
  dump str.len

Output:

.. code-block:: console

  sizeof(Foo) = 8
  sizeof(Foo()[]) = 984
  sizeof(f) = 8
  sizeof(f[]) = 984
  sizeof(@[1, 2, 3]) = 8
  sizeof(s[0]) * s.len = 24
  sizeof("foo") = 8
  sizeof(str) = 8
  str.len = 3

### When to use 'ref object' vs plain 'object'?

- https://www.reddit.com/r/nim/comments/7dm3le/tutorial_for_types_having_a_hard_time
- https://forum.nim-lang.org/t/1207

### How to pass a specific overload to a macro?

- https://forum.nim-lang.org/t/8369

### Can I use tab instead of space?

No.

### Can I use curly brace instead of indentation?

- https://forum.nim-lang.org/t/8558

### What is the difference between statement and expression?

- https://nim-lang.org/docs/manual.html#statements-and-expressions

### How to define constructor?

In Nim, everything is initialized as all bits zero.

See:
- https://nim-lang.org/docs/manual.html#statements-and-expressions-var-statement

If you want to initialize objects with other value, people usually create `createFoo` or `initFoo` procedure.

Example code:

.. code-block:: nim

  type
    Foo = object
      names: seq[string]

  proc initFoo(x: var Foo, name: string) =
    x.names.add name

  var foo: Foo
  foo.initFoo("abc")
  echo foo

  type
    Bar = ref object
      names: seq[string]

  proc createBar(name: string): Bar =
    Bar(names: @[name])

  var bar = createBar("xyz")
  echo bar[]

See also:

- https://forum.nim-lang.org/t/8311#53519

### How to use destructor?

- https://nim-lang.org/docs/destructors.html
- https://forum.nim-lang.org/t/8838

### How to get generic parameter from generic type?

.. code-block:: nim

  type
    Foo[T] = object
      x: T

    Bar = Foo[char]

  let foo = Foo[float](x: 12.3)
  echo foo.T
  echo Bar.T

### How to run code at compile time?

Expression in const statement is evaluated at compile time:

.. code-block:: nim

  proc collatz(n: int): int =
    var x = n
    while x != 1:
      if x mod 2 == 0:
        x = x div 2
      else:
        x = 3 * x + 1
      inc result

  # collatz(12) is executed at compile time.
  const a = collatz(12)

  # collatz(12) is executed at runtime time.
  let b = collatz(12)
  echo a
  echo b

- https://nim-lang.org/docs/manual.html#constants-and-constant-expressions

Use static statement/expression:

.. code-block:: nim

  proc foo(x, y: int): int =
    when nimvm: x else: y

  # Executed at runtime
  let v = foo(1, 2)
  echo v

  # foo(1, 2) is executed at compile time
  let w = static foo(1, 2)
  echo w

  # Following statement is executed at compile time
  static:
    var x = foo(1, 2)
    x = x * 7
    echo "This message is displayed at compile time"
    echo x

- https://nim-lang.org/docs/manual.html#statements-and-expressions-static-statementslashexpression
- https://nim-lang.org/docs/manual.html#statements-and-expressions-when-nimvm-statement

Use `compileTime pragma <https://nim-lang.org/docs/manual.html#pragmas-compiletime-pragma>`_.

Macro is always executed at compile time.

### How to define a procedure that takes only constant expressions?

- https://nim-lang.org/docs/manual.html#special-types-static-t

### How to define a procedure that takes types?

- https://nim-lang.org/docs/manual.html#special-types-typedesc-t

### How to define recursive object type?

You cannot define recursive object type in following way because object type is a value type and recursive object type needs infinite amount of memory:

.. code-block:: nim

  type
    Foo = object
      child: Foo

    BarX = object
      y: BarY

    BarY = object
      x: BarX

You can use ref object type in following way:

.. code-block:: nim

  type
    Foo = ref object
      child: Foo

    BarX = ref object
      y: BarY

    BarY = ref object
      x: BarX

  var foo = Foo(child: Foo())
  echo foo[].repr

  var bar = BarX(y: BarY(x: BarX()))
  echo bar[].repr

Use seq or other collection types that store values in heap:

.. code-block:: nim

  type
    Foo = object
      child: seq[Foo]

  let foo = Foo(child: @[Foo(), Foo()])
  echo foo

  import std/tables

  type
    Bar = object
      table: Table[string, Bar]

  let bar = Bar(table: toTable {{"abc": Bar(), "xyz": Bar()}})
  echo bar

### What is the difference between procedure, function and method?

Function is a procedure with `noSideEffect` pragma.

- https://nim-lang.org/docs/manual.html#effect-system-side-effects
- https://nim-lang.org/docs/manual.html#methods

### Can I define operators for my type?

You can define procedures that can be used like operators.

For example:

.. code-block:: nim

  type
    MyVector = object
      data: array[3, float]

  # You can call this proc like x + y
  proc `+`(x, y: MyVector): MyVector =
    for i in 0..2:
      result.data[i] = x.data[i] + y.data[i]

  let
    x = MyVector(data: [1.0, 2, 3])
    y = MyVector(data: [4.0, 2, 0])

  echo x + y

  proc `-`(x: MyVector): MyVector =
    for i in 0..2:
      result.data[i] = -x.data[i]

  echo -x

  # Customize how MyVector is stringified.
  proc `$$`(x: MyVector): string =
    result = "MyVector("
    for i in 0..2:
      result.add $$x.data[i]
      if i < 2:
        result.add ", "
    result.add ")"

  echo x

  type
    MyMatrix = object
      data: array[4, float]

  # You can read an element in a matrix like mat[i, j]
  proc `[]`(x: MyMatrix; i, j: int): float =
    x.data[i + j * 2]

  # You can set an element in a matrix like mat[i, j] = x
  proc `[]=`(x: var MyMatrix; i, j: int; v: float) =
    x.data[i + j * 2] = v

  var mat = MyMatrix(data: [0.0, 1, 2, 3])

  echo mat[0, 1]
  mat[1, 1] = -1
  echo mat

See also:

- https://nim-lang.org/docs/manual.html#lexical-analysis-operators
- Open Nim Manual and push F3 key and search "proc \`" to find example code that define operators

### Can i pass GC'd memory across DLL boundaries?

- https://forum.nim-lang.org/t/8598

### How to vary a return type of procedure at runtime?

You cannot change return type because Nim is a statically typed programming language.

Workarounds:

- Use `Object variants <https://nim-lang.org/docs/manual.html#types-object-variants>`_
- https://github.com/alaviss/union

### How to store different types in seq?

You cannot store different types in seq.
Each elements in seq are placed in memory continuously and you can random access each elements in O(1) because it stores only 1 type.

Workarounds:

- Use `Object variants <https://nim-lang.org/docs/manual.html#types-object-variants>`_
- https://github.com/alaviss/union

### What is the difference between stack and heap memory?

- http://zevv.nl/nim-memory/

### What is the difference between cint/cfloat and int/float?

Types with 'c' prefix are corresponding to types in C language.
cint is same to int in C and cfloat is same to float in C.
They are used when you use C functions.
sizeof(cint/cfloat) can be different from sizeof(int/float).
Size of C types vary depending on the OS, CPU or backend C compiler.
cint can be 32bits even on 64bit CPU (See `64-bit data models <https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models>`_).

Bitwidth of int in Nim is always the same as a pointer (https://nim-lang.org/docs/system.html#int).

float in Nim is always 64bit (https://nim-lang.org/docs/manual.html#types-preminusdefined-floatingminuspoint-types).

## Tools

### IDE or editor support for Nim?

- https://github.com/nim-lang/Nim/wiki/Editor-Support
- https://forum.nim-lang.org/t/8547

### How to setup github action for nim?

- https://github.com/jiro4989/setup-nim-action
- https://github.com/iffy/install-nim
- https://github.com/alaviss/setup-nim

### Is there a way to use Nim interactively? REPL for Nim?

- Run `nim secret` command
- https://github.com/inim-repl/INim

## Libraries

### Is there list of Libraries or packages for Nim?

- https://github.com/nim-lang/Nim/wiki/Curated-Packages
- https://nimble.directory
- https://github.com/xflywind/awesome-nim

### Is there GUI libraries for Nim?

- https://forum.nim-lang.org/t/8765

### Plotting library?

- https://forum.nim-lang.org/t/8569

### Can I embed NimScript to my program?

- https://github.com/beef331/nimscripter

### More Nim on more Microcontrollers!? (Arm CMSIS / Zephyr RTOS)

- https://forum.nim-lang.org/t/7731

## Use Nim with other language

### How to use C/C++ libraries in Nim?

- https://github.com/n0bra1n3r/cinterop
- https://github.com/nim-lang/c2nim
- https://github.com/PMunch/futhark
- https://github.com/treeform/genny
- https://forum.nim-lang.org/t/8451
- https://forum.nim-lang.org/t/8448
- https://nim-lang.org/docs/manual.html#foreign-function-interface
- https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-importcpp-pragma

### How to use Python with Nim?

- https://github.com/yglukhov/nimpy
- https://github.com/Pebaz/nimporter
- https://github.com/treeform/genny

### How to call Rust code from Nim?

- https://forum.nim-lang.org/t/5816

### How to use Windows .NET Frameworks from Nim?

- https://forum.nim-lang.org/t/7265
- https://khchen.github.io/winim/clr.html

## Nim Compiler

See also: `Official Nim Compiler User Guide <https://nim-lang.org/docs/nimc.html>`_

### Can I use Nim on Android?

You can use Nim compiler on android using `Termux <https://wiki.termux.com/>`_.
You can install Nim on Termux with `pkg install nim` command.

### How Nim compiler process configuration files?

`*.cfg`:
https://nim-lang.org/docs/nimc.html#compiler-usage-configuration-files

`*.nims`:
https://nim-lang.org/docs/nims.html

### How to make Android app?

- https://forum.nim-lang.org/t/8491
- https://github.com/iffy/wiish

### How to compile Nim to asmjs or wasm?

- https://forum.nim-lang.org/t/8827

### Can I get precompiled latest devel Nim?

- https://github.com/nim-lang/nightlies/releases/tag/latest-devel

### Is Nim/nimble virus or malware?

- https://forum.nim-lang.org/t/7830
- https://forum.nim-lang.org/t/7885
- https://github.com/nim-lang/Nim/issues/17820
- https://gist.github.com/haxscramper/3562fa8fee4726d7a30a013a37977df6

## Optimization

### Profiler for Nim?

- `AMD μProf <https://developer.amd.com/amd-uprof/>`_
- `Intel vTune <https://www.intel.com/content/www/us/en/develop/documentation/get-started-with-vtune/top.html>`_
- https://github.com/treeform/benchy
- https://github.com/treeform/hottie
- https://forum.nim-lang.org/t/7408
- https://forum.nim-lang.org/t/8802

### Which compiler option generate fastest executable?

`-d:danger`: Turns off all runtime checks and turns on the optimizer.

### How to write faster code?

- At first, write simple code
  - Let Nim and backend C compiler try to optimize your code
  - Complicated code is hard to debug, change and add new features
- Write a test so that you can test optimized code easily
- Find out the bottleneck
- When you change your code, always measure performance correctly
  - New code you think runs faster might actually runs slower
- Use better algorithm
- If your program is IO bound (many network or disk access) and can do multiple IO operation at same time, use asynchronous module
  - `asyncdispatch <https://nim-lang.org/docs/asyncdispatch.html>`_
  - `asyncfile <https://nim-lang.org/docs/asyncfile.html>`_
  - `asyncnet <https://nim-lang.org/docs/asyncnet.html>`_
  - `asynchttpserver <https://nim-lang.org/docs/asynchttpserver.html>`_
- If your program frequently allocates and frees heap memory, use `--mm:arc` or `--mm:orc`
- If your program is memory bound, access memory continuously and use smaller size types if possible
- If your program is computation bound, use multithreadings or SIMD instruction if possible
- Write code under procedures
  - Accessing variables outside of procedures are not much optimized
- Learn about better algorithms or details of lower layer softwares/hardware from good books or papers
- https://nim-lang.org/docs/nimc.html#optimizing-for-nim

### Which compiler option generate smallest executable?

`--opt:size`: optimize code generation for small size.
If you use gcc or clang backend compiler,
`--opt:size --passC:-flto --passL:-flto` option enables gcc/clang's link time optimization
and reduce code size.
`strip <your executable file>` command further reduce size by removing symbols and sections from your executable file.

### My code is slower than python

Pass `-d:release` or `-d:danger` option to Nim.
Nim optimize code when they are specified.
With `-d:release` runtime checks are enabled but `-d:danger` removes any runtime checks.

### Arguments are copied when it is passed to a procedure?

- https://nim-lang.github.io/Nim/manual.html#procedures-var-parameters

### How procedure return value?

- https://nim-lang.org/docs/manual.html#procedures-nrvo

## Community

### Where can I ask a question about Nim?

- https://forum.nim-lang.org/

### Where should I report security issue?

- https://github.com/nim-lang/Nim/security/policy

### How to donate to Nim?

- https://nim-lang.org/donate.html

### Is there Organization using Nim?

- https://github.com/nim-lang/Nim/wiki/Organizations-using-Nim

### Is there Game created with Nim?

- https://github.com/nim-lang/Nim/wiki/Organizations-using-Nim#gaming
- `Goodboy Galaxy <https://www.goodboygalaxy.com>`_
  - `Related Nim forum thread <https://forum.nim-lang.org/t/8375>`_

### Where is Nim Community Survey Results?

- `2021 <https://nim-lang.org/blog/2022/01/14/community-survey-results-2021.html>`_
- `2020 <https://nim-lang.org/blog/2021/01/20/community-survey-results-2020.html>`_
- `2019 <https://nim-lang.org/blog/2020/02/18/community-survey-results-2019.html>`_
- `2018 <https://nim-lang.org/blog/2018/10/27/community-survey-results-2018.html>`_
- `2017 <https://nim-lang.org/blog/2017/10/01/community-survey-results-2017.html>`_
- `2016 <https://nim-lang.org/blog/2016/09/03/community-survey-results-2016.html>`_

### Are bots in Nim Discord channel AI?

They are AIs written with Nim by AI researchers.
They learn about Nim and how to talk like human.
After enough amount of learning, they can ask or answer Nim questions like human.

It is joke. There is bridge between discord and other chat systems like IRC or matrix.
When people in other chat system write message, discord shows it with user name and bot mark.
But in the Internet, how can we know whether messages are really written by human without meeting face to face?
What if someone or something answers your Nim question is extraterrestrial intelligence or genetically engineered highly intelligent dog?
Is there any problems even if they talk about Nim politely?

.. _Nim: https://nim-lang.org/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim FAQ",
    description:"Nimに関するよくある質問と答え",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Nim FAQ",
    description:"Frequently Asked Questions about Nim programming language",
    category:"Nim"))])
newArticle(articles, rstText)
