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

### Arguments are copied when it is passed to a procedure?

- https://nim-lang.github.io/Nim/manual.html#procedures-var-parameters

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

### Can I use curly brace instead of indentation?

- https://forum.nim-lang.org/t/8558

### What is the difference between statement and expression?

- https://nim-lang.org/docs/manual.html#statements-and-expressions

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

### What is the difference between procedure, function and method.

### My code is slower than python

Pass `-d:release` or `-d:danger` option to Nim.
Nim optimize code when they are specified.
With `-d:release` runtime checks are enabled but `-d:danger` removes any runtime checks.

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

## Tools

### IDE or editor support for Nim?

- https://github.com/nim-lang/Nim/wiki/Editor-Support
- https://forum.nim-lang.org/t/8547

### Profiler for Nim?

- `AMD μProf <https://developer.amd.com/amd-uprof/>`_
- `Intel vTune <https://www.intel.com/content/www/us/en/develop/documentation/get-started-with-vtune/top.html>`_
- https://github.com/treeform/benchy
- https://github.com/treeform/hottie
- https://forum.nim-lang.org/t/7408
- https://forum.nim-lang.org/t/8802

### How to setup github action for nim?

- https://github.com/jiro4989/setup-nim-action
- https://github.com/iffy/install-nim
- https://github.com/alaviss/setup-nim

## Libraries

### Is there list of Libraries or packages for Nim?

- https://github.com/nim-lang/Nim/wiki/Curated-Packages
- https://nimble.directory
- https://github.com/xflywind/awesome-nim

### Is there GUI libraries for Nim?

- https://forum.nim-lang.org/t/8765

### Plotting library?
- https://forum.nim-lang.org/t/8569

### More Nim on more Microcontrollers!? (Arm CMSIS / Zephyr RTOS)

- https://forum.nim-lang.org/t/7731

## Use Nim with other language

### How to use C/C++ libraries in Nim?

- https://github.com/n0bra1n3r/cinterop
- https://github.com/nim-lang/c2nim
- https://github.com/PMunch/futhark
- https://forum.nim-lang.org/t/8451
- https://forum.nim-lang.org/t/8448
- https://nim-lang.org/docs/manual.html#foreign-function-interface
- https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-importcpp-pragma

### How to use Python with Nim?

- https://github.com/yglukhov/nimpy
- https://github.com/Pebaz/nimporter

### How to call Rust code from Nim?

- https://forum.nim-lang.org/t/5816

### How to use Windows .NET Frameworks from Nim?

- https://forum.nim-lang.org/t/7265
- https://khchen.github.io/winim/clr.html

## Nim Compiler

### How to make android app?

- https://forum.nim-lang.org/t/8491
- https://github.com/iffy/wiish

### How Nim compiler process configuration files?

`*.cfg`:
https://nim-lang.org/docs/nimc.html#compiler-usage-configuration-files

`*.nims`:
https://nim-lang.org/docs/nims.html

### How to compile Nim to asmjs or wasm?

- https://forum.nim-lang.org/t/8827

### Can I get precompiled latest devel Nim?

- https://github.com/nim-lang/nightlies/releases/tag/latest-devel

### Is Nim/nimble virus or malware?

- https://forum.nim-lang.org/t/7830
- https://forum.nim-lang.org/t/7885
- https://github.com/nim-lang/Nim/issues/17820
- https://gist.github.com/haxscramper/3562fa8fee4726d7a30a013a37977df6

## Community

### Where can I ask a question about Nim?

- https://forum.nim-lang.org/

### Where should I report security issue?

- https://github.com/nim-lang/Nim/security/policy

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
