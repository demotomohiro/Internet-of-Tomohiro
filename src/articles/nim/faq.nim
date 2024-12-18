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

- `Official FAQ <https://nim-lang.org/faq.html>`_
- `Another FAQ <https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ>`_

.. contents::

## Language design

### What is Zen of Nim?

- https://nim-lang.org/blog/2021/11/15/zen-of-nim.html
- https://forum.nim-lang.org/t/8630

### Why is Nim style insensitive?

- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-is-it-caseunderscore-insensitive
- https://forum.nim-lang.org/t/8497

People don't use Nim says case insensitivity cause confusion but I have never heard Nim's style insensitivity cause any problems from people use Nim.

### Why Nim use space for indent instead of tab?

- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-are-tabs-forbidden

### Why Nim use garbage collecter?

ORC is the default memory management strategy in current Nim.
For more details:
https://nim-lang.org/docs/mm.html

### Why Nim generate C/C++ code?

- C language is supported in many platforms
- A lot of effort has been spent to C compilers for long time to generate optimized executable file. Nim can use that optimizer to generate fast code.
- There are a lot of mature C/C++ libraries. Nim can easily use them.

### Is Nim a Transpiler?

No. If you say Nim is a transpiler, is GCC a transpiler from C to assembler?

- https://peterme.net/is-nim-a-transpiler.html
- https://forum.nim-lang.org/t/8520

### Why are unsigned types discouraged?

- In default, Nim checks over/under flow to signed int but unsigned int
- https://github.com/nim-lang/Nim/wiki/Unofficial-FAQ#why-are-unsigned-types-discouraged
- https://forum.nim-lang.org/t/8737

Unsigned int types are used for algorithms that randomize bit patterns.
For example:
- Pseudorandom number generator (see `random module in Nim's standard library <https://github.com/nim-lang/Nim/blob/devel/lib/pure/random.nim>`_)
- Hash (see `hashes module in Nim's standard library <https://github.com/nim-lang/Nim/blob/devel/lib/pure/hashes.nim>`_)
- Cryptography

Also used for protocols, formats or C libraries that requires unsigned int.
For example, many image file formats or pixel buffer format uses 8 bit unsigned ints for RGB color value.

### Why doesn't default import statement force fully qualify access to the imported symbols?

- https://narimiran.github.io/2019/07/01/nim-import.html


## Coding

### Can I write expressions like `x == a or x == b` shorter?

You can write it as `x in [a, b]`.

If type of x is int8, int16, uint8, uint16, char or enum, you can write it using set type:

For example:

.. code-block:: nim

  let x = 'a'
  doAssert x in {{'a'..'z', '0'..'9'}}

  type
    Direction = enum
      north, east, south, west

  let d = Direction.east
  doAssert d in {{east, west}}

### Can I write expressions like `a <= x and x <= b` shorter?

You can write it as `x in a..b`.

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

### How to echo (or stringify)  ptr or ref types?

Use `repr <https://nim-lang.org/docs/system.html#repr,T>`_.

Example code:

.. code-block:: nim

  type
    Foo = ref object
      x: int

  let a = Foo(x: 123)
  echo a.repr

  let ary = [Foo(x: 111), Foo(x: 222)]
  echo ary.repr

  var x = [0, 100, 300]
  let ptrTox = x[1].addr
  echo ptrTox.repr

Example output:

.. code-block:: console

  ref 0x7f09112ea050 --> [x = 123]
  [ref 0x7f09112ea070 --> [x = 111], ref 0x7f09112ea090 --> [x = 222]]
  ptr 0x55eda6b61108 --> 100

You can also dereference it if it is not nil and referencing valid memory location.

.. code-block:: nim

  type
    Foo = ref object
      x: int

  var a = Foo(x: 123)
  echo a[]

  var x = [0, 100, 300]
  let ptrTox = x[1].addr
  echo ptrTox[]

Example output:

.. code-block:: console

  (x: 123)
  100

Define `$$` proc for ref type. `$$` proc converts given argument to string. `$$` is implicitly called when each arguments of `echo` are stringified.

.. code-block:: nim

  type
    Foo = ref object
      x: int

  proc `$$`(foo: Foo): string =
    "Foo: " & $$foo.x

  let a = Foo(x: 123)
  echo a

Example output:

.. code-block:: console

  Foo: 123

Or use https://github.com/treeform/pretty

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

It is just an example output. Actual size of these types can be different when ARC/ORC is used or on 32bit CPU.

### I got compile error after adding or removing a space

Nim is a white-space-sensitive language.

For example:

.. code-block:: nim

  # `+` operator is used as a binary operator
  echo 1 + 1

  # Removed the space between '+' and '1'.
  # Then `+` operator is used as an unary operator.
  # And this is compile error
  echo 1 +1

.. code-block:: nim

  proc foo(x, y: int) = echo x, ", ", y

  # Call foo with 2 ints.
  foo(1, 2)

  # If you put a space between 'foo' and '(1, 2),
  # it become calling foo with a tuple (1, 2) in command invocation syntax
  # It results in compile error as there is no `foo` that takes a tuple.
  foo (1, 2)

If you want to see how Nim parses your code, use `dumpTree` macro in `macros` module:

.. code-block:: nim

  import std/macros

  dumpTree:
    echo 1 + 1
    echo 1 +1

Output:

.. code-block:: console

  StmtList
    Command
      Ident "echo"
      Infix
        Ident "+"
        IntLit 1
        IntLit 1
    Command
      Ident "echo"
      Command
        IntLit 1
        Prefix
          Ident "+"
          IntLit 1

### Can I use tab instead of space?

No.

### Can I use curly brace instead of indentation?

- https://forum.nim-lang.org/t/8558

### What is the difference between statement and expression?

- https://nim-lang.org/docs/manual.html#statements-and-expressions

### How to get each unicode characters from a string?

You can use `runes iterator <https://nim-lang.org/docs/unicode.html#runes.i%2Cstring>`_ in `unicode <https://nim-lang.org/docs/unicode.html>`_ module.
unicode module provides support to handle the Unicode UTF-8 encoding.

.. code-block:: nim

  import std/unicode

  for c in "○△□◇".runes:
    echo c

Output:

.. code-block:: console

  ○
  △
  □
  ◇

If the output didn't displayed correctly, save source code as UTF-8 encode.
Configure your console to use UTF-8 encode and use a font that support UTF-8 characters.

### How to leave nested for/while loops?

You can do it by using named `block`.

For example:

.. code-block:: nim

  block myblock:
    for i in 0..3:
      for j in 0..3:
        if i + j == 4:
          break myblock
        else:
          echo i, ", ", j

Templates or macros like this can be used for simpler code:
https://github.com/demotomohiro/littlesugar

.. code-block:: nim

  template namedWhile(name, cond, body: untyped): untyped =
    block name:
      while cond:
        body

  var x = 5
  namedWhile(myblock, x > 0):
    for i in 0..2:
      if x == 4 and i == 1:
        break myblock
      echo x, ", ", i

    dec x

### How to iterate over every field of object or tuple types?

`fieldPairs` and `fields` iterators in `iterators` standard module can do:
https://nim-lang.org/docs/iterators.html

For example:

.. code-block:: nim

  type
    MyObj = object
      name: string
      num: int
      value: float

  var x = MyObj(name: "foo", num: 2, value: 3.1)

  for i in x.fields:
    echo i

### How to modify each item inside for loop?

When `for` loop is used without explicitly specifying the iterator, `item` or `pairs` iterator is implicitly invoked.
These iterators forbid modifying items.

`mitems` and `mpairs` iterators in `iterators` standard module allow modifying items: https://nim-lang.org/docs/iterators.html

For example:

.. code-block:: nim

  var myarray = [1, 2, 3]

  for i in myarray.mitems:
    i += 2

  echo myarray

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

### Can I define custom pragmas?

There are 3 ways to create user defined pragmas:

- pragma pragma
  - You can define a new pragma by combining existing pragmas
  - https://nim-lang.org/docs/manual.html#userminusdefined-pragmas-pragma-pragma

- Custom annotations
  - You can create custom annotations that can be read by macros
  - https://nim-lang.org/docs/manual.html#userminusdefined-pragmas-custom-annotations

- Macro pragmas
  - You can use macros and templates as pragma
  - https://nim-lang.org/docs/manual.html#userminusdefined-pragmas-macro-pragmas

### Can i pass GC'd memory across DLL boundaries?

- https://forum.nim-lang.org/t/8598

### What is the difference between stack and heap memory?

- http://zevv.nl/nim-memory/

### How to use hot code reloading?

- https://nim-lang.org/docs/hcr.html

### Can Nim do pointer arithmetic?

- Use `UncheckedArray[T] <https://nim-lang.org/docs/manual.html#types-unchecked-arrays>`_

For example:

.. code-block:: nim

  var testArray = [11.cint, 22, 33]
  proc cfunc(): ptr cint = testArray[0].addr

  var p = cast[ptr UncheckedArray[cint]](cfunc())
  doAssert p[0] == 11
  doAssert p[1] == 22
  p[2] += 11
  doAssert p[2] == 44

- https://github.com/kaushalmodi/ptr_math

### How to safely convert int to enum?

https://forum.nim-lang.org/t/8188

For non-holey enum types:

.. code-block:: nim

  # Thank you PMunch!

  type MyEnum = enum
    A
    B
    C

  proc toEnum*[T](x: int): T =
    if x in T.low.int..T.high.int:
      T(x)
    else:
      raise newException(ValueError, "Value not convertible to enum")

  var a = 2
  echo toEnum[MyEnum](a)

  var b = 100
  # Error: unhandled exception: Value not convertible to enum [ValueError]
  echo toEnum[MyEnum](b)

For enum types that can be non-holey or holey:

.. code-block:: nim

  # Thank you Elegantbeef!

  import std/macros

  type
    MyEnum = enum
      A
      B
      C

    HoleyEnum = enum
      AVal = 3
      BVal = 5
      CVal = 9

  macro enumElementsAsSet(enm: typed): untyped =
    newNimNode(nnkCurly).add(enm.getType[1][1..^1])

  proc toEnum*(val: SomeInteger, E: typedesc[enum]): E =
    const enmRange = E.low.ord .. E.high.ord
    when E is Ordinal:
      if val in enmRange:
        E(val)
      else:
        raise (ref ValueError)(msg: $$val & " cannot be converted to the enum: " & $$E)
    else:
      if val in enmRange and val.E in E.enumElementsAsSet:
        E(val)
      else:
        raise (ref ValueError)(msg: $$val & " cannot be converted to the enum: " & $$E)

  var a = 5

  # Error: unhandled exception: 5 cannot be converted to the enum: MyEnum [ValueError]
  let b = a.toEnum(MyEnum)

  # Error: unhandled exception: 4 cannot be converted to the enum: HoleyEnum [ValueError]
  let c = 4.toEnum(HoleyEnum)

### Can I use unicode for variable or procedure name?

Yes you can.

.. code-block:: nim

  const π  = 3.141

  proc area□(w, h: float): float = w * h
  proc area○(radius: float): float = π  * radius * radius

  echo area□(3.0, 5.0)
  echo area○(2.0)

You can use specific unicodes for operators:
https://nim-lang.org/docs/manual.html#lexical-analysis-unicode-operators

.. code-block:: nim

  func `±`[T](x: T): (T, T) = (x, -x)
  doAssert ±3 == (3, -3)

  func `∪`[T](x, y: set[T]): set[T] = x + y
  doAssert ({{1, 2, 3}} ∪ {{2, 3, 4}}) == {{1, 2, 3, 4}}

https://forum.nim-lang.org/t/10353

### What is the difference between variables inside procedures and outside procedures?

Variables declared outside procedures are global variables and declared inside procedures are local variables.

.. code-block:: nim

  # Global variable
  var globalVar = 123

  proc bar() =
    # Local variable
    var localVar = 456

You can add an export maker '`*`' to a global variable to make it accessible in other modules, but you cannot add it to local variables.

.. code-block:: nim

  var globalVar* = 123

  proc bar() =
    # Compile error: 'export' is only allowed at top level
    var localVar* = 456

Global variables lives while the program is running. Local variables are valid until exiting enclosing block or procedure.
That means returning an address of global variable in a procedure is safe but returning an address of local variable is unsafe.

.. code-block:: nim

  type
    SomeObj = object
      name: string

  proc `=destroy`(x: SomeObj) =
    echo "Destroy ", x.name

  var globalVar = SomeObj(name: "globalVar")

  proc bar() =
    block:
      var localVarInBlock = SomeObj(name: "localVarInBlock")
      echo localVarInBlock

    var localVar = SomeObj(name: "localVar")
    echo localVar

  echo globalVar
  bar()

  echo "End of program"

Output:

.. code-block:: console

  (name: "globalVar")
  (name: "localVarInBlock")
  Destroy localVarInBlock
  (name: "localVar")
  Destroy localVar
  End of program
  Destroy globalVar

Global variables are stored in data segment (translated to C global variables when compiled with C backend) and local variables are stored in stack.
So declaring a large global variable works as long as there are enough memory but a large local variable can cause segmentation fault.

.. code-block:: nim

  import std/os

  var globalArray: array[10_000_000, int]

  proc bar() =
    # Segmentatioon fault
    var localArray: array[10_000_000, int]
    echo "localArray: ", localArray[paramCount()]

  echo "globalArray: ", globalArray[paramCount()]
  bar()

When multiple threads are created, global variables without `threadvar` pragma are not created for each threads and shared by threads. So you need to use a lock to access global variables because reading and writing to the same memory location from multiple threads at the same time is undefined behavier unless it is an atomic variable.
Local variables are created for each threads and not shared. So local variables in one thread are not read or written by other thread (as long as you don't share an address of local variabe to other thread) and you don't need to use a lock to access them.

.. code-block:: nim

  import std/locks

  var
    globalVar = 1
    thread1, thread2: Thread[int]
    lock: Lock

  proc threadProc(threadID: int) {{.thread.}} =
    var localVar: int
    withLock(lock):
      localVar = globalVar
      echo "ThreadID: ", threadID
      echo "globalVar: ", globalVar
      echo "localVar: ", localVar
      echo "addr localVar: ", cast[uint](addr localVar)
      echo "addr globalVar: ", cast[uint](addr globalVar)
      inc globalVar

  initLock(lock)
  createThread(thread1, threadProc, 1)
  createThread(thread2, threadProc, 2)
  joinThread(thread1)
  joinThread(thread2)
  deinitLock(lock)

Output:

.. code-block:: console

  ThreadID: 2
  globalVar: 1
  localVar: 1
  addr localVar: 140647661780424
  addr globalVar: 94229087072600
  ThreadID: 1
  globalVar: 2
  localVar: 2
  addr localVar: 140647663893960
  addr globalVar: 94229087072600

If the `global pragma<https://nim-lang.org/docs/manual.html#pragmas-global-pragma>`_ is applied to a local variable, it works like a global variable but you cannot access it outside the enclosing procedure.
It is initialized once at program startup and holds the value after exiting the procedure.

.. code-block:: nim

  import os

  proc foo(x: int) =
    var g {{.global.}} = 0
    g += x
    echo g

  foo(1)
  foo(2)
  foo(3)

  # Compile Error: undeclared identifier: 'g'
  #echo g

Output:

.. code-block:: console

  1
  3
  6


### Is there a type for stack(FILO, LIFO)?

You can use `seq` as stack.
Use `add <https://nim-lang.org/docs/system.html#add%2Cseq%5BT%5D%2CsinkT>`_ for push, and `pop <https://nim-lang.org/docs/system.html#pop%2Cseq%5BT%5D>`_.

.. code-block:: nim

  var stack: seq[int]
  stack.add 123
  doAssert stack.pop == 123
  doAssert stack.len == 0


### What are unsafe language features in Nim?

Nim programming language is designed so that you can write safe code.
But there are cases you need to write unsafe code.
Using C/C++ functions, writing low level code or faster code might requires to write unsafe code.
Nim provides features for such cases.

When you use unsafe features, your program passes all tests and looks like work correctly doesn't mean unsafe code is written correclty.
Invalid code doesn't always crach your program or return random results.
It might behave correclty now but it might stop working when you change other code or compile options or run it on the customers machine.

Unsafe code can be found by searching following keywords.

- `pointer`, `ptr` and `addr`

  You can use raw pointers and Nim doesn't stop you to write unsafe code.
  https://nim-lang.org/docs/manual.html#statements-and-expressions-the-addr-operator

  C functions often have pointer type parameters and a return type.
  You need to know how C, Nim and the C function use the memory to write safe code.
  You cannot know how to safely pass pointers to the C function only from the C function declaration.
  You would need to read the manual or reference of the library to safely use it.

- Type casts

  https://nim-lang.org/docs/manual.html#statements-and-expressions-type-casts
  > Type casts are a crude mechanism to interpret the bit pattern of an expression as if it would be of another type. Type casts are only needed for low-level programming and are inherently unsafe.

  `cast` doesn't convert float value `1.0` to int value `1`.
  `cast[int](1.0)` would looks like a random number, if you don't know about [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754).
  If you just want to convert float to int, do [type conversion](https://nim-lang.org/docs/manual.html#statements-and-expressions-type-conversions) like `int(floatVar)`.

  `cast[array[2, int]](@[10, 100])` doesn't return `[10, 100]` as `seq` has the different data structure from `array`.

- `noinit` pragma

  https://nim-lang.org/docs/manual.html#statements-and-expressions-var-statement

  You might get random values from variables with `noinit` pragma when you read them without initializing them.

- `emit` pragma and `asm` statement

  - https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-emit-pragma
  - https://nim-lang.org/docs/manual.html#statements-and-expressions-assembler-statement

  Nim doesn't check errors in the code in `emit` pragma or `asm` statement.

- `-d:danger`

  https://nim-lang.org/docs/nimc.html#additional-compilation-switches

  Turn off all runtime checks.

- `--mm:none`

  https://nim-lang.org/docs/mm.html
  > No memory management strategy nor a garbage collector. Allocated memory is simply never freed.

  You should check if manual memory management really makes your program faster than `--mm:arc`.

- Importing a C/C++ function with a wrong parameter/return type or calling convention

- Importing a C/C++ struct/class with a wrong field type


## Type

### What is the difference between cint/cfloat and int/float?

Types with 'c' prefix are corresponding to types in C language.
cint is same to int in C and cfloat is same to float in C.
They are used when you use C functions.
sizeof(cint/cfloat) can be different from sizeof(int/float).
Size of C types vary depending on the OS, CPU or backend C compiler.
cint can be 32bits even on 64bit CPU (See `64-bit data models <https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models>`_).

Bitwidth of int in Nim is always the same as a pointer (https://nim-lang.org/docs/system.html#int).

float in Nim is always 64bit (https://nim-lang.org/docs/manual.html#types-preminusdefined-floatingminuspoint-types).

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

### How to get generic parameter from generic type?

.. code-block:: nim

  type
    Foo[T] = object
      x: T

    Bar = Foo[char]

  let foo = Foo[float](x: 12.3)
  echo foo.T
  echo Bar.T

### When to use 'ref object' vs plain 'object'?

- https://www.reddit.com/r/nim/comments/7dm3le/tutorial_for_types_having_a_hard_time
- https://forum.nim-lang.org/t/1207
- https://forum.nim-lang.org/t/8426#54529

Reference types (`ref object`) refer an object on heap. Mutiple references can refer an object.
Reference types are actually pointers and Nim manage referenced objects so that you can use them safely.

- Many-to-one relationships
  - Many reference type variables can refer one object
  - `object` type cannot do that directly
    - Can be implemented indirectly using seq/array and index
- `a = b`
  - If `a` and `b` were `ref object` type, `a` refers same object `b` refers
  - If they were `object` type, content of `b` is copied to `a`
    - It doesn't mean an object passed to or returned from a procedure is always copied. Nim can optimize unnecessary copies.
- Where it is stored
  - Objects referenced by reference types are always stored on heap
    - Referenced object is freed only when last reference go out its scope
  - `object` type variables are stored on memory in the same way as `int` or `float` type variables
    - Object type variables declared inside procedures are stored on stack
    - They are stored on heap when they are contained in `seq` or `ref object`
- Object-oriented programming (OOP)
  - A variable of a type `A` can contain an object of another type as long as it inherits from `A` if `A` is a ref type
  - `Methods <https://nim-lang.github.io/Nim/manual.html#methods>`_ works only with reference type
- Speed
  - Copying big size object can be slow and reference types can avoid copying easily
  - Reading/writing reference type needs deferencing (Require reading pointer before accessing referenced data)
  - Objects are stored on seq/array contiguously
    - Continguous memory access is faster than random memory access
    - But inserting/deleting an element in middle of seq/array can slower

.. code-block:: nim

  type
    MyObj = object
      x: int

    MyRefObj = ref MyObj

  # Variables declared outside of procedures are on static storage.
  # Static storage lives while the program is running and its size is fixed.
  # Variables on static storage can be accessed by any procedures in same module.
  # And if they have export mark, can be accessed by any procedures in other modules importing it.

  let
    myObj = MyObj() # Exists on static storage
    myRefObj = MyRefObj() # myRefObj exists on static storage and points to MyObj type object created on heap

  proc myProc() =
    # Variables declared inside of procedures are on stack.
    # Stacks are created when a procedure is called and freed when returning from it.

    var
      myObjInProc = MyObj() # Exists on stack
      myRefObjInProc = MyRefObj() # myRefObjInProc exists on stack and points to MyObj type object created on heap

    let
      myObjInProc2 = myObjInProc  # myObjInProc2 exists on stack and myObjInProc is copied to myObjInProc2
      myRefObjInProc2 = myRefObjInProc # myRefObjInProc2 exists on stack and myRefObjInProc and myRefObjInProc2 points to same object

    myObjInProc.x = 123

    doAssert myObjInProc.x == 123
    doAssert myObjInProc2.x == 0

    myRefObjInProc.x = 321

    doAssert myRefObjInProc.x == 321
    doAssert myRefObjInProc2.x == 321

    myRefObjInProc2[] = myObjInProc # `[]` operator dereference a reference type
                                    # myObjInProc is copied to the object myRefObjInProc2 points

    doAssert myRefObjInProc.x == 123
    doAssert myRefObjInProc2.x == 123

    var
      myObjInSeq = newSeq[MyObj](4) # 4 MyObj exist on heap contiguously
      myRefObjInSeq = newSeq[MyRefObj](4) # 4 MyRefObj exist on heap contiguously and they are nil
      myRefObjInSeq2 = @[MyRefObj(x: 1), MyRefObj(x: 2), MyRefObj(x: 3), MyRefObj(x: 4)]  # each 4 MyRefObj points to 4 MyObj on heap respectively.
                                                                                          # These 4 MyObj might not placed on heap contiguously.

    myObjInSeq[0] = myObjInProc # myObjInProc is copied to myObjInSeq[0]

    myRefObjInSeq[0] = myRefObjInProc
    myRefObjInSeq[1] = myRefObjInProc2
    # myRefObjInSeq[0], myRefObjInSeq[1], myRefObjInProc and myRefObjInProc2 refers same MyObj

    myRefObjInSeq[2] = MyRefObj() # New MyObj is created on heap and myRefObjInSeq[2] refers it

    # The stack allocated for all variables in this proc is freed.
    # So all objects referenced by ref types in this scope are freed because there is no reference refers them.

  myProc()

  type
    SomeObj = object
      x: int
      o1: MyObj
      o2: MyObj   # x, o1, o2, o3 are placed on the memory contiguously
      o3: MyRefObj

    SomeRefObj = ref SomeObj

  proc myNextProc =
    var
      s = SomeObj(o3: MyRefObj()) # s.o3 refers MyObj on heap
      s2 = SomeRefObj(o3: s.o3) # SomeObj is created on heap. That means all fields of s2 (x, o1, o2, o3) are on heap.

  myNextProc()

  type
    DontCopyMe = object
      x: int

  # This proc makes copying `DontCopyMe` compile error.
  proc `=copy`(dest: var DontCopyMe; src: DontCopyMe) {{.error.}}

  var
    x, y: DontCopyMe

  # This code generates compile error
  # y = x

  echo x, y

  type
    BaseObj = object of RootObj
      x: int

    BaseRefObj = ref BaseObj

    InheritObj = object of BaseObj
      y: int
    InheritObj2 = object of BaseObj

    InheritRefObj = ref InheritObj
    InheritRefObj2 = ref InheritObj2

  proc testInheritance =
    var
      a = InheritObj(x: 7)
      b: BaseObj = a    # Copies only BaseObj part of InheritObj to b
    echo b
    # echo InheritObj(b)  # Invalid object conversion

    var
      inheritRef = InheritRefObj(y: 1234)
      baseRef: BaseRefObj = inheritRef  # baseRef points to InheritObj

    doAssert baseRef of InheritRefObj
    doAssert not (baseRef of InheritRefObj2)
    doAssert InheritRefObj(baseRef).y == 1234

  testInheritance()

### Can I pass/return object types to/from procedures if copying is disabled?

Procedures can take or return uncopyable objects but there are restrictions.
There are cases you need to add `sink` to parameters or `lent` to return type.

.. code-block:: nim

  type
    DontCopyMe = object
      x: int

  # Make copying `DontCopyMe` compile error
  proc `=copy`(dest: var DontCopyMe; src: DontCopyMe) {{.error.}}

  # See when move happen to `DontCopyMe`
  proc `=sink`(dest: var DontCopyMe; src: DontCopyMe) =
    echo "Sink! ", src.x
    dest.x = src.x

  func getX(x: DontCopyMe): int = x.x

  proc init(T: typedesc[DontCopyMe]; x: int): DontCopyMe =
    DontCopyMe(x: x)

  # func retAsIs(x: DontCopyMe): DontCopyMe = x
  # Error: '=copy' is not available for type <DontCopyMe>

  # proc takeVarAndRet(x: var DontCopyMe): DontCopyMe = x
  # Error: '=copy' is not available for type <DontCopyMe>

  proc takeVarAndRetVar(x: var DontCopyMe): var DontCopyMe = x

  proc sinkAndRet(x: sink DontCopyMe): DontCopyMe = x

  proc retLent(x: DontCopyMe): lent DontCopyMe = x

  proc test =
    let a = DontCopyMe(x: 1)
    echo getX(a)

    var b = DontCopyMe.init(10)
    echo b

    # echo retAsIs(a)

    var c = DontCopyMe(x: 2)
    # echo takeVarAndRet(c)
    echo takeVarAndRetVar(c)
    let d = sinkAndRet(c)
    echo d

    var e = retLent(DontCopyMe(x: 3))
    echo e
    # let f = retLent(e)  # Error: '=copy' is not available for type <DontCopyMe>;

  test()

  type
    HaveDontCopyMe = object
      dont: DontCopyMe

  #[
  proc init(T: typedesc[HaveDontCopyMe]; d: DontCopyMe): HaveDontCopyMe =
    HaveDontCopyMe(dont: d)
  ]#
  # Error: '=copy' is not available for type <DontCopyMe>

  proc init(T: typedesc[HaveDontCopyMe]; d: sink DontCopyMe): HaveDontCopyMe =
    HaveDontCopyMe(dont: d)

  # func getDontCopyMe(x: HaveDontCopyMe): DontCopyMe = x.dont
  # Error: '=copy' is not available for type <DontCopyMe>;

  func getDontCopyMeLent(x: HaveDontCopyMe): lent DontCopyMe = x.dont
  func getDontCopyMeVar(x: var HaveDontCopyMe): var DontCopyMe = x.dont

  # proc setDontCopyMe(x: var HaveDontCopyMe; y: DontCopyMe) = x.dont = y
  # Error: '=copy' is not available for type <DontCopyMe>;

  func setDontCopyMeSink(x: var HaveDontCopyMe; y: sink DontCopyMe) = x.dont = y

  proc test2 =
    let a = HaveDontCopyMe.init(DontCopyMe(x: 100))
    echo a

    # let b = a.getDontCopyMe()
    # echo a.getDontCopyMe()
    # let c = a.getDontCopyMeLent()
    # echo c

    echo a.getDontCopyMeLent()

    var d = HaveDontCopyMe.init(DontCopyMe(x: 110))
    d.getDontCopyMeVar().x = 111
    echo d

    # var e = HaveDontCopyMe.init(DontCopyMe(x: 120))
    # e.setDontCopyMe(DontCopyMe(x: 121))
    # echo e

    var f = HaveDontCopyMe.init(DontCopyMe(x: 130))
    f.setDontCopyMeSink(DontCopyMe(x: 131))
    echo f

    var ff = DontCopyMe(x: 142)
    f.setDontCopyMeSink(ff)
    echo f
    # echo ff # Reading `ff` cause compile error to `f.setDontCopyMeSink(ff)` in above line

  test2()

### Can I use object types for seq even if copying is disabled?

You can use uncopyable object types with seq but there are restrictions.

.. code-block:: nim

  type
    DontCopyMe = object
      x: int

  # Make copying DontCopyMe compile error
  proc `=copy`(dest: var DontCopyMe; src: DontCopyMe) {{.error.}}
  proc `=sink`(dest: var DontCopyMe; src: DontCopyMe) =
    echo "Sink! ", src.x
    dest.x = src.x

  var s: seq[DontCopyMe]
  s.add(DontCopyMe(x: 1))
  s.add(
    block:
      var a = DontCopyMe(x: 2);
      a)
  echo s

  s.setLen(64)
  echo s[^1]
  s.insert(DontCopyMe(x: 3), 60)
  echo s

  block:
    var
      sa = @[DontCopyMe(x: 4), DontCopyMe(x: 5)]
      sb = @[DontCopyMe(x: 6), DontCopyMe(x: 7)]

    # echo sa & sb # Error: '=copy' is not available for type <seq[DontCopyMe]>

  block:
    var a = DontCopyMe(x: 3)
    # s.add(a) # Compile error: '=copy' is not available for type <DontCopyMe>; requires a copy because it's not the last read of 'a'; routine: testobj
    # Variables in outside of procedures cannot be moved?

  proc test =
    block:
      var
        sl: seq[DontCopyMe]
        a = DontCopyMe(x: 11)

      sl.add(a)

      echo sl
      # echo a  # Reading `a` makes `sl.add(a)` in above line to compile error

    block:
      var
        sl = @[DontCopyMe(x: 21)]
        a = sl[0]

      echo a
      # echo sl # Reading `sl` makes `a = sl[0]` in above line to compile error
      # sl.add DontCopyMe(x: 22)  # Adding new element also makes `a = sl[0]` to compile error

      sl = @[DontCopyMe(x: 23), DontCopyMe(x: 24)]

      var
        b = sl[0]
        c = sl[1]
      echo b, c

      sl = @[DontCopyMe(x: 25), DontCopyMe(x: 26)]

      var
        idx = (cast[int](addr sl[0]) shr 5) and 1 # Get a runtime value that compiler cannot see
        d = sl[idx]
        #e = sl[idx xor 1] # Error: '=copy' is not available for type <DontCopyMe>

      echo d

    block:
      var
        sl = @[DontCopyMe(x: 31), DontCopyMe(x: 32)]
        a = sl.pop

      doAssert sl.len == 1
      doAssert a == DontCopyMe(x: 32)
      echo sl
      echo a

    block:
      var
        sa = @[DontCopyMe(x: 44), DontCopyMe(x: 45)]
        sb = @[DontCopyMe(x: 46), DontCopyMe(x: 47)]
        sab = sa & sb
      echo sab
      # echo sa # Reading `sa` makes `sab = sa & sb` in above line to compile error

  test()

### How to store different types in seq?

You cannot store different types in seq.
Each elements in seq are placed in memory continuously and you can random access each elements in O(1) because it stores only 1 type.

Workarounds:

- Use `Object variants <https://nim-lang.org/docs/manual.html#types-object-variants>`_
- https://github.com/alaviss/union
- https://github.com/beef331/fungus
- Use inheritance:

.. code-block:: nim

  # Thank you Elegantbeef!

  type
    BoxBase = ref object of RootObj
    Boxed[T] = ref object of BoxBase
      data: T

  proc boxed[T](a: T): Boxed[T] = Boxed[T](data: a)

  var a = @[BoxBase boxed"hello", boxed(10), boxed(30'd)]
  for x in a:
    if x of Boxed[int]:
      echo "int ", Boxed[int](x).data
    elif x of Boxed[float]:
      echo "float ", Boxed[float](x).data
    elif x of Boxed[string]:
      echo "string ", Boxed[string](x).data

### How pure pragma `{{.pure.}}` work to object type?

Object types can inherit from existing object if it is `RootObj`, inherits from `RootObj` or has `inheritable` pragma.
Objects with inheritance enabled has hidden runtime type information so that you can use `of` operator to determine the object's type.
In other words, objects without inheritance don't have runtime type information.

- https://nim-lang.org/docs/manual.html#types-tuples-and-object-types
- https://nim-lang.org/docs/manual.html#pragmas-final-pragma

pure pragma works to enum type differently:
https://nim-lang.org/docs/manual.html#types-enumeration-types

pure pragma remove the runtime type information even if an object can be inherit from.
Then you cannot use `of` operator to such an object.

.. code-block:: nim

  type
    PureBase {{.pure, inheritable.}} = object
      x: int64

    NonPureBase = object of RootObj
      x: int64

    FromPure = object of PureBase
      y: int64

    FromNonPure = object of NonPureBase
      y: int64

    NotInheriable = object
      x: int64
      y: int64

  proc test(a: PureBase) =
    # Error: no 'of' operator available for pure objects
    if a of FromPure:
      echo "FromPure"

  proc test(a: NonPureBase) =
    if a of FromNonPure:
      echo "FromNonPure"

  var
    pureObj = FromPure()
    nonPureObj = FromNonPure()

  echo sizeof(NotInheriable)  # 16
  echo sizeof(pureObj)        # 16
  echo sizeof(nonPureObj)     # 24

  test(pureObj)
  test(nonPureObj)

pure pragma should be used with `inheritable` pragma.
It doesn't works when an object inherits from `RootObj`.

.. code-block:: nim

  type
    PureRoot {{.pure.}} = object of RootObj
      x: int64

    FromPureRoot = object of PureRoot
      y: int64

  proc test(a: PureRoot) =
    # You can use of operator
    if a of FromPureRoot:
      echo "FromPureRoot"

  var fromPureRoot = FromPureRoot()

  echo sizeof(fromPureRoot) # 24
  test(fromPureRoot)

- https://nim-lang.org/docs/manual.html#pragmas-pure-pragma


### Why proc type doesn't match even if proc signature is same?

Even if proc signature is the same, proc types doesn't match if the calling conventions were different:
https://nim-lang.org/docs/manual.html#types-procedural-type

For example:

.. code-block:: nim

    proc foo(x: int): int =
      x + x

    proc bar(x: int): int {{.cdecl.}} =
      x * x

    proc calls(x: int; callback: proc(x: int): int {{.nimcall.}}): int =
      callback(x * 2)

    echo calls(3, foo)
    # Error: type mismatch
    echo calls(4, bar)

    proc calls2(x: int; callback: proc(x: int): int {{.closure.}}): int =
      callback(x + 1)

    echo calls2(3, foo)
    # Error: type mismatch
    echo calls2(4, bar)

See also: `Why assigning procedures to variables causes compile error?`_


## Procedures

### How to pass iterator to procedure?

- https://nim-lang.org/docs/manual.html#iterators-and-the-for-statement-firstminusclass-iterators
- https://nim-lang.org/docs/manual.html#overload-resolution-iterable

### Can Nim create class method?

Nim language doesn't have class method.
But you can define a procedure similar to class method.

.. code-block:: nim

  type
    Foo = object
      x: int

  proc myClassMethod(f: typedesc[Foo]; param: int): Foo =
    Foo(x: param)

  let foo = myClassMethod(Foo, 123)
  echo foo

### How to get a pointer to a overloaded procedure?

Type conversion can be used to disambiguate overloaded routines.

.. code-block:: nim

  proc foo(x: int) = echo x
  proc foo(x: string) = echo x

  # Compile error
  #let pfoo = foo

  let pfoo1: proc (x: int) = foo
  pfoo1(1)

  let pfoo2 = (proc (x: int))foo
  pfoo2(2)

- https://nim-lang.org/docs/manual.html#statements-and-expressions-type-conversions

### How to get a pointer to a generic procedure or a procedure with type class parameters?

Specify all generic parameters or use type conversion.

.. code-block:: nim

  proc foo[T](x: T) = echo x

  # Compile error
  #let pfoo = foo

  let pfoo1 = foo[int]
  pfoo1(1)

  let pfoo2: proc (x: int) = foo
  pfoo2(2)

  let pfoo3 = (proc (x: int))foo
  pfoo3(3)

.. code-block:: nim

  proc foo(x: int or string) = echo x

  # Compile error
  #let pfoo = foo

  let pfoo1: proc (x: int) = foo
  pfoo1(1)

  let pfoo2 = (proc (x: int))foo
  pfoo2(2)

  proc bar[T](x: int or string; y: T) = echo x, y

  let pbar1: proc (x: int; y: string) = bar
  pbar1(1, "bar")

  let pbar2 = (proc (x: int; y: string))bar
  pbar2(2, "bar")

### How to pass a specific overload to a macro?

- https://forum.nim-lang.org/t/8369

### How to define constructors?

In Nim, everything is initialized as all bits zero in default.

See:
- https://nim-lang.org/docs/manual.html#statements-and-expressions-var-statement

You can assign a constant default value to an object field. But you cannot use a runtime value as a default value:
- https://nim-lang.org/docs/manual.html#types-default-values-for-object-fields

If you want to initialize objects with arguments and initializing code, people usually create `createFoo` or `initFoo` procedure.

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

### How to define a procedure that takes types?

- https://nim-lang.org/docs/manual.html#special-types-typedesc-t

### How to pass `seq` or `array` to `varargs` parameter?

Pass them as is:

.. code-block:: nim

  proc foo(args: varargs[string]) =
    for s in args:
      echo s

  let myarray = ["foo", "bar"]
  foo(myarray)

  let myseq = @["one", "two"]
  foo(myseq)

Output:

.. code-block:: console

  foo
  bar
  one
  two

- https://nim-lang.org/docs/manual.html#types-varargs

### What is the difference between procedure, function and method?

Function is a procedure with `noSideEffect` pragma.

- https://nim-lang.org/docs/manual.html#effect-system-side-effects
- https://nim-lang.org/docs/manual.html#methods

### How to vary a return type of procedure at runtime?

You cannot change return type because Nim is a statically typed programming language.

Workarounds:

- Use `Object variants <https://nim-lang.org/docs/manual.html#types-object-variants>`_
- https://github.com/alaviss/union

### What 'GC safe' means?

We call a procedure `p` GC safe when it doesn't access any global variable that contains GC'ed memory (string, seq, ref or a closure) either directly or indirectly through a call to a GC unsafe proc.

- https://nim-lang.org/docs/manual.html#effect-system-gc-safety-effect

It is related to `Nim's memory model for threads <https://nim-lang.org/docs/manual.html#threads>`_.

### What is a calling convention?

Meaning of "Calling convention" in C/Assembler and Nim is bit different.

In C/Assembler, calling convention is about how parameters are passed to a function, result is returned and other low level rules for functions.
https://en.wikipedia.org/wiki/Calling_convention

In C or Nim language, you see no differences between functions with different calling conventions excepts function signature has different calling convention name. But they are different in assembly or machine language level.

In some platforms, many calling conventions are used.
When you call a function using a pointer to function, calling convention of the function pointer type and the calling convention of the function being called must be the same. If they are different, it results in compile error or undefined behavier.
When you call a C function from Nim and pass a pointer to Nim procedure to the C function, calling convention of the Nim procedure must be the same calling convention to the C function pointer type of the parameter.

stdcall, cdecl, safecall, fastcall, thiscall, syscall are C/C++/Assembler calling conventions and they are explained here: https://en.wikipedia.org/wiki/X86_calling_conventions

In Nim, calling convention is about C/Assembler calling convention, how Nim generate C code from Nim procedure and higher level things. This section in Nim manual lists Nim calling conventions:
https://nim-lang.org/docs/manual.html#types-procedural-type

### Why assigning procedures to variables causes compile error?

`Procedural type<https://nim-lang.org/docs/manual.html#types-procedural-type>`_

> A subtle issue with procedural types is that the calling convention of the procedure influences the type compatibility: procedural types are only compatible if they have the same calling convention. As a special extension, a procedure of the calling convention nimcall can be passed to a parameter that expects a proc of the calling convention closure.

Example code:

.. code-block:: nim

  type
    # MyProcType is closure
    MyProcType = proc (x: int)

  # Calling convention of myProc is `nimcall` and not closure.
  proc myProc(x: int) =
    echo x

  echo MyProcType is proc (x: int) {{.closure.}} # true
  echo MyProcType is proc (x: int) {{.nimcall.}} # false
  echo myProc is proc (x: int) {{.closure.}}     # false
  echo myProc is proc (x: int) {{.nimcall.}}     # true

  var a: MyProcType = myProc
  a(123)
  type MyProcType2 = proc (x: int) {{.nimcall.}}
  var b: array[2, MyProcType2] = [myproc, myproc]
  b[0](123)

  # type mismatch: got 'array[0..1, proc (x: int){{.gcsafe.}}]' for '[myProc, myProc]' but expected 'array[0..1, MyProcType]'
  # Calling convention mismatch: got '{{.nimcall.}}', but expected '{{.closure.}}'
  #var c: array[2, MyProcType] = [myproc, myproc]
  #c[0](321)

.. code-block:: nim

  proc foo(x: int): int =
    echo x
    x + 1

  # The type of myProc is the same to the type of foo.
  # Because nimcall is the default calling convention used for a Nim proc,
  # the calling convention of myProc is nimcall.
  var myProc = foo

  # if the calling convention of myProc was closure, there is no compile error.
  # closure is the default calling convention for a procedural type that lacks any pragma annotations.
  # You can assign a procedure of the calling convention nimcall to a procedural type variable of the calling convention closure.
  #var myProc: proc (x: int): int = foo

  echo myProc is proc (x: int): int {{.nimcall.}}   # true
  echo myProc is proc (x: int): int               # false

  let y = 3
  # This compiles as this proc is not a closure.
  myProc = proc (x: int): int =
    x + y
  echo myProc(2)

  proc getSomeProc(y: int): proc (x: int): int =
    let z = y * y
    # Only closure calling convention can capture local variables.
    proc (x: int): int =
      x + z

  # Error: type mismatch
  # Because getSomeProc return a proc with closure calling convention.
  myProc = getSomeProc(100)
  echo myProc(1)


### Method call syntax with generics parameter causes compile error

.. code-block:: nim

  proc foo[T](x: string) =
    echo T, x

  "Test".foo[:int]

See: `Method call syntax <https://nim-lang.org/docs/manual.html#procedures-method-call-syntax>`_


## Compile Time

Run your code in `nim c myprogram.nim` that completes before Nim output executable file or print error.

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

- Use `compileTime pragma <https://nim-lang.org/docs/manual.html#pragmas-compiletime-pragma>`_
- Macro is always executed at compile time
- Nim can also run code in `.nims` configuration files
  - https://nim-lang.org/docs/nims.html

### Is there restrictions on Compile-Time Execution?

Yes, there is `restrictions <https://nim-lang.org/docs/manual.html#restrictions-on-compileminustime-execution>`_

### How to define a procedure that takes only constant expressions?

- https://nim-lang.org/docs/manual.html#special-types-static-t

### Can I read a file at compile time?

- `staticRead <https://nim-lang.org/docs/system.html#staticRead,string>`_

### Can I execute an external command at compile time?

- `staticExec <https://nim-lang.org/docs/system.html#staticExec,string,string,string>`_
- `gorgeEx <https://nim-lang.org/docs/system.html#gorgeEx%2Cstring%2Cstring%2Cstring>`_


## Template

### What is a template?

Templates in Nim can be called like procedures and it works as if it inserts code in the call site.

It is similar to macros in C language but safer and nicer.

For example:

.. code-block:: nim

  template foo(x: string): untyped =
    echo "From template foo"
    echo x

  echo "Calling template foo"
  foo("test")

Output:

.. code-block:: console

  Calling template foo
  From template foo
  test

A difference between templates and procedures is templates can take a name and create a new variable/procedure with it in current scope or take code block.
It can also takes inline iterators using `iterable <https://nim-lang.org/docs/manual.html#overload-resolution-iterable>`_ type class.

For example:

.. code-block:: nim

  template defineProc(procName: untyped): untyped =
    proc procName() =
      echo "Procedure defined in template"

  defineProc(myProcedure)
  myProcedure()

  template declareVar(varName: untyped): untyped =
    var varName {{.inject.}} = "Variable declared in template"

  declareVar(myVariable)
  echo myVariable

Output:

.. code-block:: console

  Procedure defined in template
  Variable declared in template

Example code that takes code block:

.. code-block:: nim

  import std/[times, os]

  template measureTime(body: untyped): untyped =
    block:
      let begin = epochTime()
      body
      let delta = epochTime() - begin
      echo "Time: ", delta

  measureTime:
    os.sleep(500)
    os.sleep(600)

Output :

.. code-block:: console

  Time: 1.100237131118774

Example code that takes inline iterator:

.. code-block:: nim

  iterator myIter(n: openArray[int]): int =
    for i in n:
      yield i * i

  template myTemplate(iter: iterable[int]): int =
    var sum = 0
    for i in iter:
      sum += i
    sum

  echo myTemplate(myIter(@[-1, 0, 1]))
  echo myTemplate(1..3)

Output:

.. code-block:: console

  2
  6

Other difference is, when a procedure is called, all arguments are evaluated before the procedure runs.
In template, template body is inserted to the call site and all arguments are placed there as is.

Example code:

.. code-block:: nim

  var c = 0
  proc procWithSideEffect(): int =
    inc c
    echo "procWithSideEffect has been called ", c, " times"
    c

  proc testProc(cond: bool; x, y: int) =
    echo "In testProc"
    if cond:
      echo "x = ", x
    else:
      echo "y = ", y

  echo "Call testProc"
  testProc(true, procWithSideEffect(), procWithSideEffect())

  template testTmpl(cond: bool; x, y: int) =
    echo "In testTmpl"
    if cond:
      echo "x = ", x
    else:
      echo "y = ", y

  echo "\nCall testTmpl"
  # Content of testTmpl is inserted here and x and y in it are replaced with procWithSideEffect()
  testTmpl(true, procWithSideEffect(), procWithSideEffect())

  proc squareProc(x: int) =
    echo "In squareProc"
    echo x, " * ", x, " = ", x * x

  echo "\nCall squareProc"
  squareProc(procWithSideEffect())

  template squareTmpl(x: int) =
    echo "In squareTmpl"
    echo x, " * ", x, " = ", x * x

  echo "\nCall squareTmpl"
  squareTmpl(procWithSideEffect())

.. code-block:: console

  Call testProc
  procWithSideEffect has been called 1 times
  procWithSideEffect has been called 2 times
  In testProc
  x = 1

  Call testTmpl
  In testTmpl
  procWithSideEffect has been called 3 times
  x = 3

  Call squareProc
  procWithSideEffect has been called 4 times
  In squareProc
  4 * 4 = 16

  Call squareTmpl
  In squareTmpl
  procWithSideEffect has been called 5 times
  procWithSideEffect has been called 6 times
  procWithSideEffect has been called 7 times
  procWithSideEffect has been called 8 times
  5 * 6 = 56

You can assign a procedure to a procedural type variable, but you cannot assign a template to a variable because templates exist only at compile time.

See also:

- https://nim-lang.org/docs/manual.html#templates

### What is an `untyped` parameter type?

You can pass undeclared identifiers to `untyped` parameters to declare new variables or procedures. Or you can pass expressions/statements/code blocks that contain undeclared identifiers and use variables or procedures inside the template.

See also:

- https://nim-lang.org/docs/manual.html#templates-typed-vs-untyped-parameters

### What is a `typed` parameter type?

You can pass any expressions or statements to `typed` parameter as long as they are valid Nim code and don't use undeclared identifiers.

If your template take expressions or statements that use variables declared in the template, you need to use `untyped` parameter, not `typed`.

See also:

- https://nim-lang.org/docs/manual.html#templates-typed-vs-untyped-parameters

### Calling a template with method call syntax cause compile error

You cannot use method call syntax when first parameter of a template/macro is `untyped`.

See also:

- https://nim-lang.org/docs/manual.html#templates-limitations-of-the-method-call-syntax

### I cannot use variables/types declared in template

If you want to use variables or types declared in template outside of it, you need to use `inject` pragma. You can use procedures, iterators, converters, templates or macros defined in template outside of it without `inject` pragma.

For example:

.. code-block:: nim

  template declVarAndType(body: untyped): untyped =
    type
      Foo {{.inject.}} = object
        x: int

    var myVar {{.inject.}} = "Variable in template"
    body

  declVarAndType:
    let f = Foo()
    echo myVar

  let g = Foo(x: 123)
  echo myVar

See also:

- https://nim-lang.org/docs/manual.html#templates-hygiene-in-templates

### How to pass multiple code blocks to a template?

You can pass multiple code blocks to a template or macro using do notation.

For example:

.. code-block:: nim

  template foo(x: bool; bodyA, bodyB: untyped): untyped =
    if x:
      bodyA
    else:
      bodyB

  foo(false) do:
    echo "bodyA"
  do:
    echo "bodyB"


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
  - There are `restrictions <https://nim-lang.org/docs/manual.html#restrictions-on-compileminustime-execution>`_
- https://github.com/inim-repl/INim
- Install `nlvm <https://github.com/arnetheduck/nlvm>`_ and run `nlvm r <https://github.com/arnetheduck/nlvm?tab=readme-ov-file#repl--running-your-code>`_
  - https://forum.nim-lang.org/t/10697


## Libraries

### Is there list of Libraries or packages for Nim?

- https://github.com/nim-lang/Nim/wiki/Curated-Packages
- https://nimble.directory
- https://github.com/ringabout/awesome-nim

### Is there GUI libraries for Nim?

- https://forum.nim-lang.org/t/8765

### Plotting library?

- https://forum.nim-lang.org/t/8569

### Can I embed NimScript to my program?

- https://github.com/beef331/nimscripter

### More Nim on more Microcontrollers!? (Arm CMSIS / Zephyr RTOS)

- https://forum.nim-lang.org/t/7731

### Is there a list of programming language libraries for Nim or implementations written by Nim?

- https://gist.github.com/haxscramper/3562fa8fee4726d7a30a013a37977df6


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

### How to wrap `const char*` type in C?

.. code-block:: nim

  type
    cstringConstImpl {{.importc:"const char*".}} = cstring
    constChar* = distinct cstringConstImpl

  {{.emit: "const char* foo() {{return \"hello\";}}".}}
  proc foo(): constChar {{.importc.}} # change to importcpp for C++ backend
  echo foo().cstring

- https://dev.to/xflywind/wrap-const-char-in-the-nim-language-53no
- https://github.com/nim-lang/Nim/issues/19588

### Nim bindings for the C++ STL?

- https://github.com/Clonkk/nim-cppstl
- https://forum.nim-lang.org/t/9007


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

- https://github.com/treeform/nim_emscripten_tutorial
- https://forum.nim-lang.org/t/8827
- `nlvm supports wasm32<https://github.com/arnetheduck/nlvm?tab=readme-ov-file#wasm32-support>`_

### Can I get precompiled latest devel Nim?

- https://github.com/nim-lang/nightlies/releases/tag/latest-devel

### How to produce assembler code?

There are 2 ways to produce assembler code:

- Run Nim with `--asm` option
  - It produces assembler code in nimcache directory with `.asm` extension

- Pass options to the backend C compiler or the linker to produce assembler code
  - When GCC or Clang is used as backend C compiler: `nim c --passC:-S mycode.nim`
    - Produces assembler code in nimcache directory with `.o` extension
    - It get error at link time because it generates assembler code instead of object file
    - It doesn't work when LTO (link-time optimizer) runs because `-S` option generates assembler code at the compile time not the link time
  - When LTO is enabled:
    - GCC:
      - `nim c -d:lto --passL:"-Wa,-acdl=/path/to/mycode.asm" mycode.nim`
        - `-Wa` option passes `-acdl` option to the assembler GCC calls
        - If your GCC uses an assembler other than GNU assembler `as` in Binutils, it can fail
      Or
      - `nim c -d:lto --passL:"-save-temps -dumpbase asmout/mycode" mycode.nim`
        - Create asmout directory before run this
        - Produces assembler code in asmout directory with `.s` extension
    - Clang:
      - `nim c -d:lto --passL:"-Wl,--lto-emit-asm" mycode.nim` or
      - `nim c -d:lto --passL:"-Wl,-plugin-opt=emit-asm" mycode.nim`
      - Produced assembler code has same name as executable file
  - If you want intel syntax assembler code, add `--passC:-masm=intel` option

### How to stop showing console window when my program starts?

Compile your code with `--app:gui` option like:

.. code-block:: console

  $$ nim c --app:gui myprog.nim

For example:

.. code-block:: nim

  import winim

  doAssert MessageBoxA(0, "Hello world", "Nim", MB_OK)

When you start your program on windows explorer, new console window will open if you compiled it without `--app:gui` option.

.. code-block:: console

  $$ nim c test myprog.nim

If you compile it with `--app:gui`, your program runs without opening console window.

### Is Nim/nimble virus or malware?

Nim and tools distributed with Nim are neither virus nor malwares. They are safe to use.

Many people reported Nim and executables compiled with Nim were detected by antivirus softwares but they are false positive.

- https://forum.nim-lang.org/t/7830
- https://forum.nim-lang.org/t/7885
- https://forum.nim-lang.org/t/9388
- https://forum.nim-lang.org/t/9850
- https://forum.nim-lang.org/t/10820
- https://forum.nim-lang.org/t/10824
- https://forum.nim-lang.org/t/10851
- https://forum.nim-lang.org/t/11031
- https://forum.nim-lang.org/t/11087
- `Nim and Go programs identified by Carbon Black as malware on Windows <https://news.ycombinator.com/item?id=34594743>`_
- https://github.com/nim-lang/Nim/issues/17820
- https://github.com/nim-lang/Nim/issues/23151
- https://github.com/nim-lang/Nim/issues/23307

It seems Nim was used to write malware and it might related to false detections by many Antivirus softwares:
- https://thehackernews.com/2021/03/researchers-spotted-malware-written-in.html
- https://thehackernews.com/2023/12/decoy-microsoft-word-documents-used-to.html

And it seems antivirus softwares don't analyze the program carefully, but just alarm when they spot a bit pattern that has been seem in other malware.

Please do not write malware in Nim.

- `The Nim team's latest efforts in mitigating the false postives on the Nim binaries <https://forum.nim-lang.org/t/9358>`_
- https://github.com/nim-lang/virus_checker


## Optimization

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

### Profiler for Nim?

- `AMD μProf <https://developer.amd.com/amd-uprof/>`_
- `Intel vTune <https://www.intel.com/content/www/us/en/develop/documentation/get-started-with-vtune/top.html>`_
- https://github.com/treeform/benchy
- https://github.com/treeform/hottie
- https://forum.nim-lang.org/t/7408
- https://forum.nim-lang.org/t/8802

### Which compiler option generate fastest executable?

- `-d:danger`
  Turns off all runtime checks and turns on the optimizer.
- `-d:lto`
  Enables link time optimization.
If you use gcc or clang backend compiler,
- `--passC:"-march=native"`
  Produces code optimized for the local machine.
  The produced code might not run on different machines because it enables all instruction subsets supported by the local machine.
  See:
  https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html#index-march-16

Example command:

.. code-block:: console

  $$ nim c -d:danger -d:lto --passC:"-march=native" test.nim

### Which compiler option generate smallest executable?

- `--opt:size`
  code generation for small size.
- `--mm:arc`
  Set Memory Management Strategies to ARC that produce less code compared to other memory managements.
  But it might leak memory if there is a circular reference.
  See `Nim's Memory Management <https://nim-lang.org/docs/mm.html>`_ for more details.
- `-d:lto`
  Enables link time optimization and reduce code size.
If you use gcc or clang backend compiler,
- `-d:strip`
  Further reduce size by removing symbols and sections from your executable file.
  `strip <your executable file>` command do same thing.

Example command:

.. code-block:: console

  $$ nim c -d:danger --mm:arc -d:lto -d:strip --opt:size test.nim

See `Nim Compiler User Guide<https://nim-lang.org/docs/nimc.html>`_ for more details.

### My code is slower than python

Pass `-d:release` or `-d:danger` option to Nim.
Nim optimize code when they are specified.
With `-d:release` runtime checks are enabled but `-d:danger` removes any runtime checks.

### Arguments are copied when it is passed to a procedure?

- https://nim-lang.github.io/Nim/manual.html#procedures-var-parameters

### How procedure return value?

- https://nim-lang.org/docs/manual.html#procedures-nrvo

### Nim cannot be as fast as C or Rust because Nim uses garbage collector?

Nim can be as fast as C or Rust without turn off memory management.
Using GC doesn't mean every objects are placed on heap.
You can choose to place arrays or objects in stack and they are not managed by GC.
You can control memory layout of data structure like C.

.. code-block:: nim

  type
    Vec3 = object
      x, y, z: float32

    Triangle = object
      v: array[3, Vec3]

  # float32 are placed on memory continuously
  doAssert sizeof(array[16, Triangle]) == sizeof(float32) * 3 * 3 * 16

RefC (Default Garbage collector), ORC and ARC don't start garbage collection at random timing.
If you don't allocate new heap in inner loop, garbage collection doesn't start in the loop.

These memory managements add a counter to each heap memory.
Most of case, memory usage increase due to a counter is tiny because objects allocated in the heap is larger than a counter.
As they don't use atomic instruction, cost of incrementing/decrementing counter is tiny unless you just copy reference types and don't do other thing. The Nim compiler also aggressively optimizes away RC ops and exploits `move semantics <https://nim-lang.org/docs/destructors.html#move-semantics>`_.

### If there are unused procedures, they makes executable file bigger?

Nim do dead code elimination.


## Macro

### What is macro?

Like templates work as if it inserts Nim code where it is called, macros work as if it inserts some code where it is called. Unlike template, you construct a data structure called "abstract syntax tree" (AST) in macro.

An AST is a tree data consists of nodes that is easy to handle for compiler and macro.
When Nim compiles your code, it constructs AST from your source code.
Some nodes have variable number of other nodes as children, and other nodes are leaf nodes don't have child.
Reaf nodes correspond to number/string literals or name of variable, procedure, iterator, etc.
Nodes also have kind field.

For example, expression `x + 123` (`x` is int variable) becomes a node with `Infix` kind that has 3 children, `Ident` (identifier) kind node with name "+", `Ident` kind node with name "x" and `IntLit` (int literal) kind node with number "123".

Following code prints AST of `x + 123` using `dumpTree <https://nim-lang.org/docs/macros.html#dumpTree.m%2Cuntyped>`_ in `macros module <https://nim-lang.org/docs/macros.html#dumpTree.m,untyped>`_ at compile time:

.. code-block:: nim

  import macros

  let x = 1
  dumpTree(x + 123)

Output:

.. code-block:: console

  Infix
    Ident "+"
    Ident "x"
    IntLit 123

You can use `dumpTree` to prints AST of any Nim code:

.. code-block:: nim

  import macros

  dumpTree:
    let x = 1
    echo x + 123

Output:

.. code-block:: console

  StmtList
    LetSection
      IdentDefs
        Ident "x"
        Empty
        IntLit 1
    Command
      Ident "echo"
      Infix
        Ident "+"
        Ident "x"
        IntLit 123

`NimNode <https://nim-lang.org/docs/macros.html#the-ast-in-nim>`_ type repesents a node in AST and `NimNodeKind <https://nim-lang.org/docs/macros.html#NimNodeKind>`_ enum repesents a kind of node.

Macros can take expressions or statements and they become `NimNode` AST in macro.
So you can access any child nodes inside given nodes.
You can analyze given expressions or statements in macro.
You can transform them to construct new AST or just put them inside newly created AST and return it.
AST you constructed and returned in your macro is inserted in where your macro is called.

Writing a Nim macro is like a writing a program that program a program.

### Is there any tutorial or documents to learn about macro?

- `Nim Tutorial <https://nim-lang.org/docs/tut3.html>`_
- https://dev.to/beef331/demystification-of-macros-in-nim-13n8
- https://nim-lang.org/docs/macros.html
- https://nim-lang.org/docs/manual.html#macros

### How to pass a int or string type as is?

A macro with `int` type parameters takes any expression with `int` and it become `NimNode` in the macro:

.. code-block:: nim

  import macros

  macro foo(x: int): untyped =
    echo typeof(x)
    echo x.treeRepr

  var
    x = 1
    y = 2
  foo(x + y)

Output:

.. code-block:: console

  NimNode
  Infix
    Sym "+"
    Sym "x"
    Sym "y"

If you want to write a macro that takes `int` value as is, use `static[int]`:

.. code-block:: nim

  import macros

  macro foo(x: static[int]): untyped =
    echo typeof(x)
    echo x

  foo(123)

Output:

.. code-block:: console

  int
  123

### How to write a code that can be shared by multiple macros?

Macro can call procedures as long as it can be executed at compile time.
You can implement procedures that can transform AST like you do in macros using `NimNode` parameters and return type.

.. code-block:: nim

  import macros

  proc addEcho(x: NimNode): NimNode =
    newCall(bindSym"echo", x)

  macro fooEcho(x: string): untyped =
    x.addEcho

  macro fooEcho(x: int): untyped =
    x.addEcho

  fooEcho("test")
  fooEcho(100 + 23)

### Can I see what Nim code a macro generate?

- Use `expandMacros <https://nim-lang.org/docs/macros.html#expandMacros.m,typed>`_

### How to echo NimNode?

- `treeRepr <https://nim-lang.org/docs/macros.html#treeRepr,NimNode>`_
- `lispRepr <https://nim-lang.org/docs/macros.html#lispRepr,NimNode>`_
- `astGenRepr <https://nim-lang.org/docs/macros.html#astGenRepr%2CNimNode>`_
- `repr <https://nim-lang.org/docs/system.html#repr,T>`_

.. code-block:: nim

  import macros

  macro foo(x: float): untyped =
    echo "treeRepr:"
    echo x.treeRepr
    echo ""
    echo "lispRepr:"
    echo x.lispRepr
    echo ""
    echo "astGenRepr:"
    echo x.astGenRepr
    echo ""
    echo "repr:"
    echo x.repr

  let
    x = 1.0
    y = 10.0
  foo(x + y)

Output:

.. code-block:: console

  treeRepr:
  Infix
    Sym "+"
    Sym "x"
    Sym "y"

  lispRepr:
  (Infix (Sym "+") (Sym "x") (Sym "y"))

  astGenRepr:
  nnkInfix.newTree(
    newSymNode("+"),
    newSymNode("x"),
    newSymNode("y")
  )

  repr:
  x + y

### How to pass multiple code blocks to a macro?

You can pass multiple code blocks to a template or macro using do notation.

For example:

.. code-block:: nim

  import macros

  macro foo(bodyA, bodyB: untyped): untyped =
    echo bodyA.treeRepr
    echo bodyB.treeRepr

  foo() do:
    echo "bodyA"
  do:
    echo "bodyB"

### How to get the type of a variable or expression in a macro?

Make a macro with `typed` parameters and use `getType <https://nim-lang.org/docs/macros.html#getType%2CNimNode>`_ or `getTypeImpl <https://nim-lang.org/docs/macros.html#getTypeImpl%2CNimNode>`_ proc in macros module in the macro.

For example:

.. code-block:: nim

  import macros

  macro getVarType(exp: typed): untyped =
    echo "----"
    echo exp.treeRepr
    echo exp.getType.treeRepr
    echo exp.getTypeImpl.treeRepr

  var x = 0
  getVarType(x)

  type
    Foo = object
      x: int

  getVarType(Foo(x: 10))
  getVarType([1, 4, 6])

Example output:

.. code-block:: console

  ----
  Sym "x"
  Sym "int"
  Sym "int"
  ----
  ObjConstr
    Sym "Foo"
    ExprColonExpr
      Sym "x"
      IntLit 10
  ObjectTy
    Empty
    Empty
    RecList
      Sym "x"
  ObjectTy
    Empty
    Empty
    RecList
      IdentDefs
        Sym "x"
        Sym "int"
        Empty
  ----
  Bracket
    IntLit 1
    IntLit 4
    IntLit 6
  BracketExpr
    Sym "array"
    BracketExpr
      Sym "range"
      IntLit 0
      IntLit 2
    Sym "int"
  BracketExpr
    Sym "array"
    Infix
      Ident ".."
      IntLit 0
      IntLit 2
    Sym "int"


## Community

### Where can I ask a question about Nim?

- https://forum.nim-lang.org/
- https://reddit.com/r/nim
- https://stackoverflow.com/questions/tagged/nim-lang

Chat:

- irc://irc.libera.chat/nim
- https://discord.gg/nim
- https://gitter.im/nim-lang/Nim
- https://matrix.to/#/#nim:envs.net
- https://t.me/nim_lang

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
- `Games made with Nico <https://itch.io/c/1064082/games-made-with-nico>`_

### Where is Nim Community Survey Results?

- `2023 <https://nim-lang.org/blog/2024/01/31/community-survey-results-2023.html>`_
- 2022 (No survey)
- `2021 <https://nim-lang.org/blog/2022/01/14/community-survey-results-2021.html>`_
- `2020 <https://nim-lang.org/blog/2021/01/20/community-survey-results-2020.html>`_
- `2019 <https://nim-lang.org/blog/2020/02/18/community-survey-results-2019.html>`_
- `2018 <https://nim-lang.org/blog/2018/10/27/community-survey-results-2018.html>`_
- `2017 <https://nim-lang.org/blog/2017/10/01/community-survey-results-2017.html>`_
- `2016 <https://nim-lang.org/blog/2016/09/03/community-survey-results-2016.html>`_

### How to post Nim code with syntax highlight on Discord?

Enclose your code with `\`\`\`nim` and `\`\`\`` like:

.. code-block:: nim

  ```nim
  var
    x = 1
    y = 2

  echo x + y
  ```

### How to use NimBot on Nim IRC/Discord?

You can run one line Nim code with `!eval echo "Hello"`.

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
