const rstText = """
# How Nim's runtime checks are optimized out

.. contents::

Nim compiler adds runtime check code like over-/underflow checks or bound checks to an output program in default.
`-d:danger` compiler flag turn off all runtime checks.
This blog post shows that if the compiler found the runtime error never happens, corresponding runtime check code can be removed and in some cases it might run fast as if it is compiled with `-d:danger`.
GCC's optimizer perform `Jump threading<https://en.wikipedia.org/wiki/Jump_threading>`_ that do such an optimization.

I used Nim version 2.0.8, GCC version 13.2.1 20240210 (Gentoo 13.2.1_p20240210 p14) and x86_64 intel ivybridge CPU on Gentoo Linux.

## Simple openArray read with an index

`testproc.nim`:

.. code-block:: nim

  proc testProc(arr: openArray[int]; pos: int): int =
    # Integer addition adds overflow check
    let p = pos + 3

    # Reading an openArray element adds bound check
    arr[p]

  const arr = [0, 1, 2, 3, 4]
  echo testProc(arr, 1)

Following command compiles above code and generates C code (`@mtestproc.nim.c`), GIMPLE intermediate language (`@mtestproc.nim.c.c.254t.optimized`) and assembler code (`@mtestproc.nim.c.o`) in Nim cache directory.
`--passC` option send specified options to the backend C compiler. In my case it is GCC.
As `-S` option output an assembly code instead of an object file, this command fails at linking.
All Nim code in this article are also compiled with this command with corresponding file name.

.. code-block:: cmd

  nim c -d:release --passC:"-S -masm=intel -fno-asynchronous-unwind-tables -fverbose-asm -fdump-tree-optimized" testproc.nim

- `-S`: Output an assembler code (in `$$NimCacheDir/@mtestproc.nim.c.o`)
- `-masm=intel`: Output assembly instructions using intel dialect (Only for x86 or x86_64 target)
- `-fno-asynchronous-unwind-tables`: Reduce some noise from assembler code
- `-fverbose-asm`: Adds the C source code lines associated with the assembly instructions
- `-fdump-tree-optimized`: Dump the intermediate language tree (GIMPLE) after target and language independent optimizations to a file (in `$$NimCacheDir`/@mtestproc.nim.c.c.254t.optimized`)
  - It writes trees as C-like representation and easier to read than an assembly code
Read `GCC manual for more details<https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html>`_.
-  `-fno-schedule-insns2`: Disable the optimization that reorder assembly instructions. This option makes an output assembly code easier to read but it might be slower.

You can read output assembly files and see how GCC optimize code.
But if you don't like to read an assembly code, you can read the file dumped by `-fdump-tree-optimized` option which writes the intermediate language tree called GIMPLE after optimizations.
GIMPLE is a language independent tree based representation used by GCC for target and language independent optimizations.
As it is written to the file in C like syntax, it is easier to read than an assembly code.
If you want to learn more about GIMPLE, please read `GCC Internals Manual<https://gcc.gnu.org/onlinedocs/gccint/>`_.

Following code represents generated C code as Nim code. There are branches to check runtime errors:

.. code-block:: nim

  proc testProc(arr_p0: ptr int; arr_p0Len_0: int; pos_p1: int): int =
    var tmp: int
    # `nimAddInt` do addition with overflow check.
    if nimAddInt(pos_p1, 3, tmp.addr):
      raiseOverflow()

    var p = tmp
    # if statement for bound check
    if p < 0 or p >= arr_p0Len_0:
      raiseIndexError2(p, arr_p0Len_0-1)

    result = arr_p0[p]

Following code is the intermediate language tree dumped by `-fdump-tree-optimized`:

.. Note:: `<bb 3>` represents a block and `goto <bb 3>` jump to the block. `# result_11 = PHI <result_20(D)(6), result_18(7)>` means if jumped from `<bb 6>`, assign `result_20` to `result_11`. And if jumped from `<bb 7>`, assign `result_18` to `result_11`. For more details: https://gcc.gnu.org/onlinedocs/gccint/SSA.html

.. code-block:: c

  NI testProc__testproc_u1 (NI * arr_p0, NI arr_p0Len_0, NI pos_p1)
  {
    NI result;
    long long int _1;
    long long int _2;
    _Bool _4;
    _Bool _5;
    _Bool _6;
    long int _7;
    long unsigned int p.1_8;
    long unsigned int _9;
    NI * _10;
    __complex__ long long int _14;

    <bb 2> [local count: 1073741824]:
    _14 = .ADD_OVERFLOW (pos_p1_13(D), 3);
    _1 = REALPART_EXPR <_14>;
    _2 = IMAGPART_EXPR <_14>;
    if (_2 != 0)
      goto <bb 3>; [20.24%]
    else
      goto <bb 4>; [79.76%]

    <bb 3> [local count: 217325344]:
    raiseOverflow ();
    goto <bb 6>; [100.00%]

    <bb 4> [local count: 856416481]:
    _4 = _1 < 0;
    _5 = _1 >= arr_p0Len_0_16(D);
    _6 = _4 | _5;
    if (_6 != 0)
      goto <bb 5>; [20.24%]
    else
      goto <bb 7>; [79.76%]

    <bb 5> [local count: 173338695]:
    _7 = arr_p0Len_0_16(D) + -1;
    raiseIndexError2 (_1, _7);

    <bb 6> [local count: 173338695]:
    goto <bb 8>; [100.00%]

    <bb 7> [local count: 683077786]:
    p.1_8 = (long unsigned int) _1;
    _9 = p.1_8 * 8;
    _10 = arr_p0_17(D) + _9;
    result_18 = *_10;

    <bb 8> [local count: 1073741824]:
    # result_11 = PHI <result_20(D)(6), result_18(7)>
  BeforeRet_:
    return result_11;

  }

Following code is the assembly code (`/$$NimCacheDir/@mtestproc.nim.c.o`) generated by GCC on x86_64 Linux:

.. Note:: `testProc` proc is actually inlined at the call site and it is optimized and became a code just do `echo $$4`. I put the assembly code of `testProc` to show how `testProc` is compiled if it is not inlined and the value of arguments are unknown at the compile time.

List of registers used to pass arguments and the return value:
- `rdi`: Pointer part of `arr` parameter. `arr_p0` in C (First integer/pointer argument)
- `rsi`: Length of `arr` parameter. `arr_p0Len_0` in C (Second integer/pointer argument)
- `rdx`: pos (Third integer/pointer argument)
- `rax`: return value

.. code-block::

  testProc__testproc_u1:
    endbr64
    sub	rsp, 24
    # let p = pos + 3
    add	rdx, 3
    # If pos + 3 overflow, jump to .L3 and raiseOverflow
    jo	.L3
    # If p < 0, jump to .L9 and raiseIndexError
    test	rdx, rdx
    js	.L9
    # if p >= arr_p0Len_0, jump to .L9 and raiseIndexError
    cmp	rdx, rsi
    jge	.L9
    # rax = arr[p];
    mov	rax, QWORD PTR [rdi+rdx*8]
  .L8:
  .L1:
    add	rsp, 24
    ret
    .p2align 4,,10
    .p2align 3
  .L9:
    # raiseIndexError2(p,arr_p0Len_0-1)
    sub	rsi, 1
    mov	rdi, rdx
    mov	QWORD PTR 8[rsp], rax
    call	raiseIndexError2
    mov	rax, QWORD PTR 8[rsp]
    add	rsp, 24
    ret
  .L3:
    mov	QWORD PTR 8[rsp], rax
    # raiseOverflow()
    call	raiseOverflow
    mov	rax, QWORD PTR 8[rsp]
    jmp	.L1

Add the if statement that do bound check to `testProc` proc.

`testproc.nim`:

.. code-block:: nim

  proc testProc(arr: openArray[int]; pos: int): int =
    let p = pos + 3

    if p >= 0 and p < arr.len:  # Added if statement.
      arr[p]
    else:
      0

  const arr = [0, 1, 2, 3, 4]
  echo testProc(arr, 1)

Compile it with the same command and see how output files are changed.
You can see GCC removes the branch corresponding to the bound check code because the index is always within the bound of `openArray` after the added if statement.

Following code is a Nim code translated from Generated C code and simplified.
There are the if statement corresponding to the added if statement and bound check.

.. code-block:: nim

  proc testProc__testproc_u1(arr_p0: ptr int, arr_p0Len_0: int, pos_p1: int): int
    var tmp: int
    if nimAddInt(pos_p1, 3, tmp.addr):
      raiseOverflow()

    if p < 0 or p >= arr_p0Len_0:
      result = 0
    elif p < 0 or p >= arr_p0Len_0:
      raiseIndexError2(p,arr_p0Len_0-1)
    else:
      result = arr_p0[p]
    return result;

In the intermediate language tree, there is only one branch (`<bb 4>`) that do bound check.

.. code-block:: c

  NI testProc__testproc_u1 (NI * arr_p0, NI arr_p0Len_0, NI pos_p1)
  {
    NI colontmpD_;
    NI result;
    long long int _1;
    long long int _2;
    _Bool _7;
    long unsigned int p.1_8;
    long unsigned int _9;
    NI * _10;
    __complex__ long long int _15;
    _Bool _18;
    _Bool _21;

    <bb 2> [local count: 1073741823]:
    _15 = .ADD_OVERFLOW (pos_p1_14(D), 3);
    _1 = REALPART_EXPR <_15>;
    _2 = IMAGPART_EXPR <_15>;
    if (_2 != 0)
      goto <bb 3>; [20.24%]
    else
      goto <bb 4>; [79.76%]

    <bb 3> [local count: 217325344]:
    raiseOverflow ();
    goto <bb 6>; [100.00%]

    <bb 4> [local count: 856416479]:
    _18 = _1 < arr_p0Len_0_17(D);
    _7 = _1 >= 0;
    _21 = _7 & _18;
    if (_21 != 0)
      goto <bb 5>; [65.24%]
    else
      goto <bb 6>; [34.76%]

    <bb 5> [local count: 378707366]:
    p.1_8 = (long unsigned int) _1;
    _9 = p.1_8 * 8;
    _10 = arr_p0_19(D) + _9;
    colontmpD__20 = *_10;

    <bb 6> [local count: 1073741824]:
    # result_11 = PHI <result_22(D)(3), colontmpD__20(5), _2(4)>
  LA1_:
  BeforeRet_:
    return result_11;

  }

In the assembly code, the bound check is performed only once.

.. code-block::

  testProc__testproc_u1:
    endbr64
    # result = 0  (bitwise xor same values result in 0)
    xor	eax, eax
    # let p = pos + 3
    add	rdx, 3
    # if overflowed, set 1 to al, else set 0 to al.
    seto	al
    # Jump to .L15 if overflowed.
    jo	.L15
    # If p < 0, jump to .L9 and raiseIndexError
    test	rdx, rdx
    js	.L11
    # if p >= arr_p0Len_0, jump to .L9 and raiseIndexError
    cmp	rdx, rsi
    jge	.L11
  .L5:
  .L6:
    # rax = arr[p];
    mov	rax, QWORD PTR [rdi+rdx*8]
   	# return
    ret
    .p2align 4,,10
    .p2align 3
  .L11:
    ret
    .p2align 4,,10
    .p2align 3
  .L15:
    sub	rsp, 24
    mov	QWORD PTR 8[rsp], rax
    # raiseOverflow()
    call	raiseOverflow
    mov	rax, QWORD PTR 8[rsp]
    add	rsp, 24
    ret

## For loop

Next, let's see if runtime check code is optimized away in for statement.
In following code, `testloop` proc finds the maximum value from the `openArray` type argument.

`testforloop.nim`:

.. code-block:: nim

  import std/[cmdline, times, monotimes, random]

  template bench(body: untyped): untyped =
    let start = getMonoTime()
    body
    let finish = getMonoTime()
    echo (finish - start).inMicroseconds, " micro second"

  type MyInt = int

  proc testloop(arr: openArray[MyInt]): MyInt =
    result = MyInt.low
    for x in arr:
      if x > result:
        result = x

  # Initialize inputData using a runtime value `paramCount()`
  # so that compilers cannot optimize code using input data
  # that are known at compile time.
  var
    rand = (paramCount() or 123).initRand()
    inputData: seq[MyInt]

  for i in 0 .. (10000000 + paramCount()):
    inputData.add rand.rand(MyInt)

  var ret: MyInt
  bench:
    ret = testloop(inputData)
  # If output of `testloop` was not echoed, dead code elimination
  # would optimize out `testloop`.
  echo ret

In generated C code, in the loop in `testloop` proc, there is no overflow check when incrementing the counter because the loop ends when the counter reached to openArray length.
But there is a bound check code before reading `openArray`.
Can I access the openArray with the index larger than the openArray length in the for loop?

.. code-block:: c

  N_LIB_PRIVATE N_NIMCALL(NI, testloop__testforloop_u10)(NI* arr_p0, NI arr_p0Len_0) {
    NI result;
  {	result = ((NI)(IL64(-9223372036854775807) - IL64(1)));
    {
      NI* x;
      NI i;
      x = (NI*)0;
      i = ((NI)0);
      {
        while (1) {
          if (!(i < arr_p0Len_0)) goto LA3;
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          x = (&arr_p0[i]);
          {
            if (!(result < (*x))) goto LA6_;
            result = (*x);
          }
  LA6_: ;
          i += ((NI)1);
        } LA3: ;
      }
    }
    }BeforeRet_: ;
    return result;
  }

This is probably because `iterator items*[T: not char](a: openArray[T]): lent2 T` in `lib/system/iterators.nim` in Nim stdlib is implemented using while loop and access elements using index.

.. code-block:: nim

  iterator items*[T: not char](a: openArray[T]): lent2 T {.inline.} =
    ## Iterates over each item of `a`.
    var i = 0
    while i < len(a):
      yield a[i]
      unCheckedInc(i)

In the intermediate language tree, there is no bound check in the loop.
I think, GCC knows variable `i` is initialized with 0 and exit the loop when `i == arr_p0Len_0`, so also knows `i < 0 || i >= arr_p0Len_0` is always false.

.. Note:: `testloop` proc is actually inlined at the call site and following code is not called. But it is almost the same as inlined code and you can see how optimization worked.

.. code-block:: c

  NI testloop__testforloop_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    unsigned long ivtmp.31;
    NI result;
    long int _4;
    unsigned long _6;
    long int _7;
    unsigned long _17;
    unsigned long _18;
    void * _19;

    <bb 2> [local count: 118111600]:
    if (arr_p0Len_0_8(D) <= 0)
      goto <bb 3>; [11.00%]
    else
      goto <bb 4>; [89.00%]

    <bb 3> [local count: 118111600]:
    # result_14 = PHI <_7(5), -9223372036854775808(2)>
    return result_14;

    <bb 4> [local count: 105119324]:
    ivtmp.31_20 = (unsigned long) arr_p0_9(D);
    _18 = (unsigned long) arr_p0Len_0_8(D);
    _17 = _18 * 8;
    _6 = _17 + ivtmp.31_20;

    <bb 5> [local count: 955630225]:
    # result_15 = PHI <_7(5), -9223372036854775808(4)>
    # ivtmp.31_22 = PHI <ivtmp.31_21(5), ivtmp.31_20(4)>
    _19 = (void *) ivtmp.31_22;
    _4 = MEM[(NI *)_19];
    _7 = MAX_EXPR <_4, result_15>;
    ivtmp.31_21 = ivtmp.31_22 + 8;
    if (_6 == ivtmp.31_21)
      goto <bb 3>; [11.00%]
    else
      goto <bb 5>; [89.00%]

  }

In assembly code, there is no bound check.
Also, it read and update max value twice in one loop iteration.

.. Note:: `testloop` proc is actually inlined at the call site and following code is not executed. But it is almost the same as inlined code and you can see how optimization worked. And inlined code is a bit complicated than this.

.. code-block::

  testloop__testforloop_u10:
    endbr64
    # rdi: pointer to an array of int. The pointer part of openArray.
    # rsi: Length of openArray.
    # rax: return value.

    # if arr.len_0 <= 0, jump to .L11
    test	rsi, rsi
    jle	.L11
    # result = int.low
    movabs	rax, -9223372036854775808
    # rcx points to the last element in openArray
    lea	rcx, [rdi+rsi*8]
    # if arr.len is an even number, jump to .L4
    and	esi, 1
    je	.L4
    # if x > result:
    #   result = x
    mov	rdx, QWORD PTR [rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    # Add 8 to rdi and jump to .L12 when rdi == rcx
    add	rdi, 8	# ivtmp.31,
    cmp	rcx, rdi	# _6, ivtmp.31
    je	.L12	#,
    .p2align 4,,10
    .p2align 3
  .L4:
    # Main loop
    # if x > result:
    #   result = x
    mov	rdx, QWORD PTR [rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	rdx, QWORD PTR 8[rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    add	rdi, 16
    cmp	rcx, rdi
    jne	.L4
    ret
    .p2align 4,,10
    .p2align 3
  .L11:
    # return int.low
    movabs	rax, -9223372036854775808
    ret
  .L12:
    ret

I compiled `testforloop.nim` with `-d:danger`. Generated assembly code for `testloop` proc was the same as the one compiled with `-d:release`.
So the measured time of `testloop` proc using `bench` template are the same.

I compiled `testforloop.nim` with `-d:danger --passC:"-march=native"`.
(`-march=native` is explained here: https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html#index-march-16)
(You can get the same assembly code with `-march=ivybridge` as I'm using ivybridge CPU)
There are SSE instructions in the loop that takes 2 int and find the largest value at the same time. But it tooks about x1.5 longer time.
I usually get faster code with `-march=native`, but it seems not always produce faster code.
So measuring time to see if changed code or compile options produces faster code is important.

GCC also generated SSE instructions when I changed `type MyInt = int32` in `testforloop.nim` even if it compiled without `--passC:"-march=native"`.

Following table shows measured times when I change `MyInt` type and `-march=native` option. In all cases, there is no difference between `-d:release` and `-d:danger`.

======   ===============   ====================
MyInt    GCC option        time (10^-3 second)
======   ===============   ====================
int64    <empty>           20.7
"        `-march=native`   30.9
int32    <empty>           6.14
"        `-march=native`   4.53
======   ===============   ====================

## While loop

I replaced for loop in `testforloop.nim` with while loop.
Then, there are two openArray element accesses that produce bound checks and the integer addition that produces an overflow check.
So while loop runs slower than for loop?

`testwhileloop.nim`:

.. code-block:: nim

  import std/[cmdline, times, monotimes, random]

  template bench(body: untyped): untyped =
    let start = getMonoTime()
    body
    let finish = getMonoTime()
    echo (finish - start).inMicroseconds, " micro second"

  type MyInt = int

  proc testloop(arr: openArray[MyInt]): MyInt =
    result = MyInt.low
    var i = 0
    while i < arr.len:
      if arr[i] > result:
        result = arr[i]
      inc i

  # Initialize inputData using a runtime value `paramCount()`
  # so that compilers cannot optimize code using input data
  # that are known at compile time.
  var
    rand = (paramCount() or 123).initRand()
    inputData: seq[MyInt]

  for i in 0 .. (10000000 + paramCount()):
    inputData.add rand.rand(MyInt)

  var ret: MyInt
  bench:
    ret = testloop(inputData)
  # If output of `testloop` was not echoed, dead code elimination
  # would optimize out `testloop`.
  echo ret

In generated C code for `testloop` proc in `testwhileloop.nim`, variable `i` was bound checked twice while its value is not changed.
When incrementing variable `i`, it is overflow checked.

.. code-block:: c

  N_LIB_PRIVATE N_NIMCALL(NI, testloop__testwhileloop_u10)(NI* arr_p0, NI arr_p0Len_0) {
    NI result;
    NI i;
  {	result = ((NI)(IL64(-9223372036854775807) - IL64(1)));
    i = ((NI)0);
    {
      while (1) {
        NI TM__aOy9cqT9aUiLxScXJWTKXVXA_4;
        if (!(i < arr_p0Len_0)) goto LA2;
        {
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          if (!(result < arr_p0[i])) goto LA5_;
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          result = arr_p0[i];
        }
  LA5_: ;
        if (nimAddInt(i, ((NI)1), &TM__aOy9cqT9aUiLxScXJWTKXVXA_4)) { raiseOverflow(); goto BeforeRet_;
        };
        i = (NI)(TM__aOy9cqT9aUiLxScXJWTKXVXA_4);
      } LA2: ;
    }
    }BeforeRet_: ;
    return result;
  }

The intermediate language tree generated from `testwhileloop.nim` is almost the same as the one generated from `testforloop.nim`.
There is neither bound check nor overflow checks inside the loop.

.. code-block:: c

  NI testloop__testwhileloop_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    unsigned long ivtmp.33;
    NI result;
    long int _7;
    long int _8;
    unsigned long _12;
    unsigned long _14;
    unsigned long _16;
    void * _17;

    <bb 2> [local count: 113634474]:
    if (arr_p0Len_0_20(D) <= 0)
      goto <bb 5>; [3.66%]
    else
      goto <bb 3>; [96.34%]

    <bb 3> [local count: 109475452]:
    ivtmp.33_18 = (unsigned long) arr_p0_21(D);
    _16 = (unsigned long) arr_p0Len_0_20(D);
    _14 = _16 * 8;
    _12 = _14 + ivtmp.33_18;

    <bb 4> [local count: 996582262]:
    # result_25 = PHI <_8(4), -9223372036854775808(3)>
    # ivtmp.33_23 = PHI <ivtmp.33_22(4), ivtmp.33_18(3)>
    _17 = (void *) ivtmp.33_23;
    _7 = MEM[(NI *)_17];
    _8 = MAX_EXPR <_7, result_25>;
    ivtmp.33_22 = ivtmp.33_23 + 8;
    if (_12 == ivtmp.33_22)
      goto <bb 5>; [3.66%]
    else
      goto <bb 4>; [96.34%]

    <bb 5> [local count: 113634474]:
    # result_11 = PHI <_8(4), -9223372036854775808(2)>
  LA2:
  BeforeRet_:
    return result_11;

  }

Generated assembly code from `testwhileloop.nim` is also almost the same as the one from `testforloop.nim` excepts `rax` register is initialized in different order.

.. code-block::

  testloop__testwhileloop_u10:
    endbr64
  .L2:
  .L4:
    movabs	rax, -9223372036854775808
    test	rsi, rsi
    jle	.L1
    lea	rcx, [rdi+rsi*8]
    and	esi, 1
    je	.L3
    mov	rdx, QWORD PTR [rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    add	rdi, 8
    cmp	rcx, rdi
    je	.L13
    .p2align 4,,10
    .p2align 3
  .L3:
    mov	rdx, QWORD PTR [rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	rdx, QWORD PTR 8[rdi]
    cmp	rax, rdx
    cmovl	rax, rdx
    add	rdi, 16
    cmp	rcx, rdi
    jne	.L3
  .L1:
    ret
  .L13:
    ret

I measured time of `testwhileloop.nim` with `MyInt = int`/`MyInt = int32` and with/without `-march=native` and I got almost the same result as `testforloop.nim`.
`-d:release` and `-d:danger` options didn't affected measured time again.

## While loop with a loop counter incremented by 2

If the loop counter `i` incremented by 2 instead of 1, bound checks and the overflow check inside the loop is still optimized away?

`testwhileloop2.nim`:

.. code-block:: nim

  import std/[cmdline, times, monotimes, random]

  template bench(body: untyped): untyped =
    let start = getMonoTime()
    body
    let finish = getMonoTime()
    echo (finish - start).inMicroseconds, " micro second"

  type MyInt = int

  proc testloop(arr: openArray[MyInt]): MyInt =
    result = MyInt.low
    var i = 0
    while i < arr.len:
      if arr[i] > result:
        result = arr[i]
      inc i, 2

  # Initialize inputData using a runtime value `paramCount()`
  # so that compilers cannot optimize code using input data
  # that are known at compile time.
  var
    rand = (paramCount() or 123).initRand()
    inputData: seq[MyInt]

  for i in 0 .. (10000000 + paramCount()):
    inputData.add rand.rand(MyInt)

  var ret: MyInt
  bench:
    ret = testloop(inputData)
  # If output of `testloop` was not echoed, dead code elimination
  # would optimize out `testloop`.
  echo ret

In generated C code, there are bound checks and a overflow check.

.. code-block:: c

  N_LIB_PRIVATE N_NIMCALL(NI, testloop__testwhileloop50_u10)(NI* arr_p0, NI arr_p0Len_0) {
    NI result;
    NI i;
  {	result = ((NI)(IL64(-9223372036854775807) - IL64(1)));
    i = ((NI)0);
    {
      while (1) {
        NI TM__1WLdxhZPcWspJNZcZVZa7A_4;
        if (!(i < arr_p0Len_0)) goto LA2;
        {
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          if (!(result < arr_p0[i])) goto LA5_;
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          result = arr_p0[i];
        }
  LA5_: ;
        if (nimAddInt(i, ((NI)2), &TM__1WLdxhZPcWspJNZcZVZa7A_4)) { raiseOverflow(); goto BeforeRet_;
        };
        i = (NI)(TM__1WLdxhZPcWspJNZcZVZa7A_4);
      } LA2: ;
    }
    }BeforeRet_: ;
    return result;
  }

In intermediate language tree, there are `raiseIndexError2` and `raiseOverflow`.

.. code-block:: c

  NI testloop__testwhileloop50_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    NI i;
    NI result;
    long int _3;
    long unsigned int i.0_4;
    long unsigned int _5;
    NI * _6;
    long int _7;
    long int _8;
    long long int _10;
    long long int _11;
    __complex__ long long int _21;

    <bb 2> [local count: 113634474]:

    <bb 3> [local count: 1073741824]:
    # result_12 = PHI <-9223372036854775808(2), _8(7)>
    # i_14 = PHI <0(2), _10(7)>
    if (i_14 >= arr_p0Len_0_18(D))
      goto <bb 4>; [3.66%]
    else
      goto <bb 5>; [96.34%]

    <bb 4> [local count: 39298952]:
    goto <bb 9>; [100.00%]

    <bb 5> [local count: 1034442872]:
    if (i_14 < 0)
      goto <bb 6>; [3.66%]
    else
      goto <bb 7>; [96.34%]

    <bb 6> [local count: 37860610]:
    _3 = arr_p0Len_0_18(D) + -1;
    raiseIndexError2 (i_14, _3);
    goto <bb 4>; [100.00%]

    <bb 7> [local count: 996582262]:
    i.0_4 = (long unsigned int) i_14;
    _5 = i.0_4 * 8;
    _6 = arr_p0_19(D) + _5;
    _7 = *_6;
    _8 = MAX_EXPR <_7, result_12>;
    _21 = .ADD_OVERFLOW (i_14, 2);
    _10 = REALPART_EXPR <_21>;
    _11 = IMAGPART_EXPR <_21>;
    if (_11 != 0)
      goto <bb 8>; [3.66%]
    else
      goto <bb 3>; [96.34%]

    <bb 8> [local count: 36474912]:
    raiseOverflow ();

    <bb 9> [local count: 113634474]:
    # result_13 = PHI <_8(8), result_12(4)>
  LA2:
  BeforeRet_:
    return result_13;

  }

In assembly code, there are `call	raiseIndexError2` and `call	raiseOverflow`.

.. code-block::

  testloop__testwhileloop50_u10:
    endbr64
    push	rbx
    # pointer part of `arr` is copied to rdx
    mov	rdx, rdi
    # rdi is zero cleared and it is used as loop counter `i`
    xor	edi, edi
    # rbx = int.low. It correspondings to `result`.
    movabs	rbx, -9223372036854775808
    jmp	.L8
    .p2align 4,,10
    .p2align 3
  .L16:
    # if rdi < 0, jump to .L14 and raiseIndexError2
    test	rdi, rdi
    js	.L14
    # rax = `arr[i]`
    mov	rax, QWORD PTR [rdx+rdi*8]
    # if rbx < rax, rbx = rax
    cmp	rbx, rax
    cmovl	rbx, rax
    # Add 2 to rdi and if overflowed, jump to .L15 and raiseOverflow
    add	rdi, 2
    jo	.L15
  .L8:
    # if rdi > arr.len, exit loop
    cmp	rdi, rsi
    jl	.L16
    # rax = rbx as rax is the return value of this proc.
    mov	rax, rbx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L14:
    sub	rsi, 1
    call	raiseIndexError2
    mov	rax, rbx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L15:
  .L3:
  .L9:
    call	raiseOverflow
    mov	rax, rbx
    pop	rbx
    ret

In both the intermediate language tree and the assembly code, when adding 2 to loop counter `i` (`i_14` in the intermediate language true and `rdi` in the assembly code), it is overflow checked.
Before accessing openArray, the bound check only see if `i < 0`, but doesn't check `i >= arr.len`.
This is probably because the length of openArray can be highest int value. If `arr.len == int.high`, loop counter `i` becomes `i == int.high - 1` (int.high - 1 is an even number) and adding 2 to it causes overflow without while loop condition `i < arr.len` become false, as `int.high` is an odd number but `i` is always an even number.

How slow if there are an overflow check and a bound check?

======   ===============   =============   ====================
MyInt    GCC option        `-d:`           time (10^-3 second)
======   ===============   =============   ====================
int64    <empty>           `-d:release`    11.7
"        "                 `-d:danger`     10.9
"        `-march=native`   `-d:release`    11.7
"        "                 `-d:danger`     10.9
int32    <empty>           `-d:release`    10.4
"        "                 `-d:danger`      4.71
"        `-march=native`   `-d:release`    10.3
"        "                 `-d:danger`      4.04
======   ===============   =============   ====================

When `MyInt = int64`, `-d:danger` is slightly faster but no so much difference. But when `MyInt = int32`, `-d:release` is almost 2 times slower than `-d:danger`.

Following two assembly code generated from `testwhileloop2.nim` with `MyInt = int32` without `-march=native`.

In the assembly code compiled with `-d:release`, there is no SSE instructions.

.. code-block::

  testloop__testwhileloop50_u10:
    endbr64
    push	rbx
    mov	rdx, rdi
    mov	ebx, -2147483648
    xor	edi, edi
    jmp	.L8
    .p2align 4,,10
    .p2align 3
  .L16:
    test	rdi, rdi
    js	.L14
    mov	eax, DWORD PTR [rdx+rdi*4]
    cmp	ebx, eax
    cmovl	ebx, eax
    add	rdi, 2
    jo	.L15
  .L8:
    cmp	rdi, rsi
    jl	.L16
    mov	eax, ebx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L14:
    sub	rsi, 1
    call	raiseIndexError2
    mov	eax, ebx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L15:
  .L3:
  .L9:
    call	raiseOverflow
    mov	eax, ebx
    pop	rbx
    ret

In the assembly code compiled with `-d:danger`, there are SSE instructions.

.. code-block::

  testloop__testwhileloop50_u10:
    endbr64
    # Let natural numbers 'n' and 'm' such that `arr.len` = 8 * n + m (0 <= m < 8) (Division theorem)
    # When m == 0, first 8 * (n - 1) elements in `arr` are read in the main loop .L5,
    # and remaining 8 elements are read after .L3.
    # When m != 0, first 8 * n elements in `arr` are read in the main loop,
    # and remaining elements are read after .L3.

    # rcx is the pointer part of `arr: openArray[int32]`
    mov	rcx, rdi
    # If `arr.len <= 0`, jump to .L10 and return int32.low
    test	rsi, rsi
    jle	.L10
    # rdx = `arr.len - 1`
    lea	rdx, -1[rsi]
    # If `arr.len <= 8`, jump to .L8
    # The main loop below .L5 works only when `arr.len > 8`.
    cmp	rdx, 7
    jbe	.L8
    shr	rdx, 3
    # rax is the pointer part of `arr: openArray[int32]`
    # rax is used as read pointer in the main loop.
    mov	rax, rdi
    # xmm register contains 4 int32. Set int32.low to 4 int32 in xmm2.
    movdqa	xmm2, XMMWORD PTR .LC0[rip]
    mov	rdi, rdx
    sal	rdi, 5
    # rdi points to the byte after the last int32 * 8 block
    add	rdi, rcx
    .p2align 4,,10
    .p2align 3
  .L5:
    # The main loop is between this line and `jne .L5`.
    # Read 4 int32 and store to xmm0
    movdqu	xmm0, XMMWORD PTR [rax]
    # Read next 4 int32 and store to xmm3
    movdqu	xmm3, XMMWORD PTR 16[rax]
    # Add 32 to read pointer
    add	rax, 32
    # 136 = 10001000
    # Pick 1st and 3rd int32 from each of xmm0 and xmm3 and put them on xmm0,
    # so that xmm0 contains 4 int32 from even number element of `arr`.
    shufps	xmm0, xmm3, 136
    movdqa	xmm1, xmm0
    # Compare each int32 in xmm1 and xmm2, and if the one in xmm1 is larger, set it to xmm2.
    pcmpgtd	xmm1, xmm2
    pand	xmm0, xmm1
    pandn	xmm1, xmm2
    movdqa	xmm2, xmm1
    por	xmm2, xmm0
    cmp	rdi, rax
    jne	.L5
    # Pick larget int32 from xmm2 and set it to eax
    movdqa	xmm0, xmm2
    sal	rdx, 3
    psrldq	xmm0, 8
    movdqa	xmm1, xmm0
    pcmpgtd	xmm1, xmm2
    pand	xmm0, xmm1
    pandn	xmm1, xmm2
    por	xmm1, xmm0
    movdqa	xmm2, xmm1
    psrldq	xmm2, 4
    movdqa	xmm0, xmm2
    pcmpgtd	xmm0, xmm1
    pand	xmm2, xmm0
    pandn	xmm0, xmm1
    por	xmm0, xmm2
    movd	eax, xmm0
  .L3:
    mov	r8d, DWORD PTR [rcx+rdx*4]
    lea	rdi, 0[0+rdx*4]
    cmp	eax, r8d
    cmovl	eax, r8d
    lea	r8, 2[rdx]
    cmp	r8, rsi
    jge	.L1
    mov	r8d, DWORD PTR 8[rcx+rdi]
    cmp	eax, r8d
    cmovl	eax, r8d
    lea	r8, 4[rdx]
    cmp	rsi, r8
    jle	.L1
    mov	r8d, DWORD PTR 16[rcx+rdi]
    cmp	eax, r8d
    cmovl	eax, r8d
    add	rdx, 6
    cmp	rsi, rdx
    jle	.L1
    mov	edx, DWORD PTR 24[rcx+rdi]
    cmp	eax, edx
    cmovl	eax, edx
  .L1:
    ret
    .p2align 4,,10
    .p2align 3
  .L10:
    mov	eax, -2147483648
    ret
  .L8:
    # Zero clear rdx and set int32.low to eax
    xor	edx, edx
    mov	eax, -2147483648
    jmp	.L3

## Try to improve while loop with a loop counter incremented by 2

In order to make bound checks and overflow checks are optimized out in `testloop` proc in `testwhileloop2.nim`,  I have changed the loop condition.
If `i < arr.len - 1`, `inc i, 2` should not overflow even if `arr.len == int.high`.
But it exits the loop before the last even number element is read when `arr.len` is an odd number.

`testwhileloop2a.nim`:

.. code-block:: nim

  import std/[cmdline, times, monotimes, random]

  template bench(body: untyped): untyped =
    let start = getMonoTime()
    body
    let finish = getMonoTime()
    echo (finish - start).inMicroseconds, " micro second"

  type MyInt = int

  proc testloop(arr: openArray[MyInt]): MyInt =
    result = MyInt.low

    var i = 0
    while i < arr.len - 1:
      if arr[i] > result:
        result = arr[i]
      inc i, 2

    if i == arr.high and arr[i] > result:
      result = arr[i]

  when false:
    # Tests
    doAssert testloop([]) == MyInt.low
    doAssert testloop([0.MyInt]) == 0
    doAssert testloop([0.MyInt, 1]) == 0
    doAssert testloop([0.MyInt, 1, 2]) == 2
    doAssert testloop([0.MyInt, 1, 2, 3]) == 2
    doAssert testloop([0.MyInt, 1, 2, 3, 4]) == 4
    doAssert testloop([0.MyInt, 1, 2, 3, 4, 5]) == 4

  # Initialize inputData using a runtime value `paramCount()`
  # so that compilers cannot optimize code using input data
  # that are known at compile time.
  var
    rand = (paramCount() or 123).initRand()
    inputData: seq[MyInt]

  for i in 0 .. (10000000 + paramCount()):
    inputData.add rand.rand(MyInt)

  var ret: MyInt
  bench:
    ret = testloop(inputData)
  # If output of `testloop` was not echoed, dead code elimination
  # would optimize out `testloop`.
  echo ret

In generated C code, `arr.len - 1` in the while loop condition became `nimSubInt(arr_p0Len_0, ((NI)1), &TM__ZnbSUaan7pLK3wwky39bzhA_4)`.
It is an integer subtraction with underflow check.
`arr.len` is an int and should be larger than or equal to 0.
Can `arr.len - 1` cause underflow?

.. code-block:: c

  N_LIB_PRIVATE N_NIMCALL(NI, testloop__testwhileloop50a_u10)(NI* arr_p0, NI arr_p0Len_0) {
    NI result;
    NI i;
  {	result = ((NI)(IL64(-9223372036854775807) - IL64(1)));
    i = ((NI)0);
    {
      while (1) {
        NI TM__ZnbSUaan7pLK3wwky39bzhA_4;
        NI TM__ZnbSUaan7pLK3wwky39bzhA_5;
        if (nimSubInt(arr_p0Len_0, ((NI)1), &TM__ZnbSUaan7pLK3wwky39bzhA_4)) { raiseOverflow(); goto BeforeRet_;
        };
        if (!(i < (NI)(TM__ZnbSUaan7pLK3wwky39bzhA_4))) goto LA2;
        {
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          if (!(result < arr_p0[i])) goto LA5_;
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          result = arr_p0[i];
        }
  LA5_: ;
        if (nimAddInt(i, ((NI)2), &TM__ZnbSUaan7pLK3wwky39bzhA_5)) { raiseOverflow(); goto BeforeRet_;
        };
        i = (NI)(TM__ZnbSUaan7pLK3wwky39bzhA_5);
      } LA2: ;
    }
    {
      NIM_BOOL T9_;
      T9_ = (NIM_BOOL)0;
      T9_ = (i == (arr_p0Len_0-1));
      if (!(T9_)) goto LA10_;
      if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
      }
      T9_ = (result < arr_p0[i]);
  LA10_: ;
      if (!T9_) goto LA11_;
      if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
      }
      result = arr_p0[i];
    }
  LA11_: ;
    }BeforeRet_: ;
    return result;
  }

In intermediate language tree, there are still `raiseIndexError2` and `raiseOverflow`.

.. code-block:: c

  NI testloop__testwhileloop50a_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    NI i;
    NI result;
    long long int _1;
    long long int _2;
    long int _7;
    _Bool _13;
    long unsigned int i.2_15;
    long int _20;
    long int _21;
    _Bool _22;
    long unsigned int i.5_23;
    long unsigned int _24;
    NI * _25;
    long int _26;
    __complex__ long long int _41;
    _Bool _43;
    long unsigned int _53;
    NI * _54;
    long int _55;
    __complex__ long long int _56;
    long long int _57;
    long long int _58;

    <bb 2> [local count: 113328220]:
    _41 = .SUB_OVERFLOW (arr_p0Len_0_40(D), 1);
    _1 = REALPART_EXPR <_41>;
    _2 = IMAGPART_EXPR <_41>;
    if (_2 != 0)
      goto <bb 6>; [2.75%]
    else
      goto <bb 3>; [97.25%]

    <bb 3> [local count: 1044213920]:
    # result_3 = PHI <-9223372036854775808(2), _55(5)>
    # i_12 = PHI <_2(2), _57(5)>
    if (_1 <= i_12)
      goto <bb 7>; [2.75%]
    else
      goto <bb 4>; [97.25%]

    <bb 4> [local count: 987571835]:
    _43 = i_12 < 0;
    _13 = i_12 >= arr_p0Len_0_40(D);
    _22 = _13 | _43;
    if (_22 != 0)
      goto <bb 8>; [2.75%]
    else
      goto <bb 5>; [97.25%]

    <bb 5> [local count: 960413607]:
    i.2_15 = (long unsigned int) i_12;
    _53 = i.2_15 * 8;
    _54 = arr_p0_42(D) + _53;
    _21 = *_54;
    _55 = MAX_EXPR <result_3, _21>;
    _56 = .ADD_OVERFLOW (i_12, 2);
    _57 = REALPART_EXPR <_56>;
    _58 = IMAGPART_EXPR <_56>;
    if (_58 != 0)
      goto <bb 10>; [2.75%]
    else
      goto <bb 3>; [97.25%]

    <bb 6> [local count: 29527904]:
    raiseOverflow ();
    goto <bb 15>; [100.00%]

    <bb 7> [local count: 28715887]:
    _20 = arr_p0Len_0_40(D) + -1;
    if (i_12 != _20)
      goto <bb 14>; [50.00%]
    else
      goto <bb 11>; [50.00%]

    <bb 8> [local count: 27926200]:
    _7 = arr_p0Len_0_40(D) + -1;
    raiseIndexError2 (i_12, _7);

    <bb 9> [local count: 27926200]:
    goto <bb 15>; [100.00%]

    <bb 10> [local count: 27158229]:
    raiseOverflow ();
    goto <bb 15>; [100.00%]

    <bb 11> [local count: 14357943]:
    if (i_12 < 0)
      goto <bb 12>; [20.24%]
    else
      goto <bb 13>; [79.76%]

    <bb 12> [local count: 2906048]:
    raiseIndexError2 (i_12, i_12);
    goto <bb 14>; [100.00%]

    <bb 13> [local count: 11451896]:
    i.5_23 = (long unsigned int) i_12;
    _24 = i.5_23 * 8;
    _25 = arr_p0_42(D) + _24;
    _26 = *_25;
    if (result_3 < _26)
      goto <bb 15>; [66.00%]
    else
      goto <bb 14>; [34.00%]

    <bb 14> [local count: 3447781]:
    goto <bb 9>; [100.00%]

    <bb 15> [local count: 113328219]:
    # result_34 = PHI <result_3(9), -9223372036854775808(6), _55(10), _26(13)>
  LA11_:
  BeforeRet_:
    return result_34;

  }

In assembly code, there are `call	raiseIndexError2` and `call	raiseOverflow`.

.. code-block::

  testloop__testwhileloop50a_u10:
    endbr64
    mov	rcx, rsi
    push	rbx
    sub	rcx, 1
    jo	.L4
    movabs	rbx, -9223372036854775808
    mov	rdx, rdi
    seto	dil
    movzx	edi, dil
    jmp	.L10
    .p2align 4,,10
    .p2align 3
  .L22:
    cmp	rdi, rsi
    jge	.L6
    test	rdi, rdi
    js	.L6
    mov	rax, QWORD PTR [rdx+rdi*8]
    cmp	rbx, rax
    cmovl	rbx, rax
    add	rdi, 2
    jo	.L21
  .L10:
    cmp	rcx, rdi
    jg	.L22
    sub	rsi, 1
    cmp	rdi, rsi
    jne	.L1
    test	rdi, rdi
    js	.L23
    mov	rax, QWORD PTR [rdx+rdi*8]
    cmp	rbx, rax
    cmovl	rbx, rax
  .L11:
  .L16:
  .L1:
    mov	rax, rbx
    pop	rbx
    ret
  .L4:
    movabs	rbx, -9223372036854775808
    call	raiseOverflow
    mov	rax, rbx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L6:
    sub	rsi, 1
    call	raiseIndexError2
    mov	rax, rbx
    pop	rbx
    ret
    .p2align 4,,10
    .p2align 3
  .L21:
    call	raiseOverflow
    mov	rax, rbx
    pop	rbx
    ret
  .L23:
    mov	rsi, rdi
    call	raiseIndexError2
    jmp	.L1

`arr.len - 1` is underflow checked probably because `arr_p0Len_0` in C (corresponding to `arr.len` in Nim) is an int type argument and GCC assumes it can be smallest int value.

## While loop with a loop counter incremented by 2 without runtime checks

So I have added an if statement so that GCC can see that `arr.len - 1` in the while loop never underflowed.

`testwhileloop2faster.nim`:

.. code-block:: nim

  import std/[cmdline, times, monotimes, random]

  template bench(body: untyped): untyped =
    let start = getMonoTime()
    body
    let finish = getMonoTime()
    echo (finish - start).inMicroseconds, " micro second"

  type MyInt = int

  proc testloop(arr: openArray[MyInt]): MyInt =
    result = MyInt.low

    # if statement to make sure `arr.len - 1` never underflow
    if arr.len == int.low:
      return

    var i = 0
    while i < arr.len - 1:
      if arr[i] > result:
        result = arr[i]
      inc i, 2

    if i == arr.high and arr[i] > result:
      result = arr[i]

  when true:
    # Tests
    doAssert testloop([]) == MyInt.low
    doAssert testloop([0.MyInt]) == 0
    doAssert testloop([0.MyInt, 1]) == 0
    doAssert testloop([0.MyInt, 1, 2]) == 2
    doAssert testloop([0.MyInt, 1, 2, 3]) == 2
    doAssert testloop([0.MyInt, 1, 2, 3, 4]) == 4
    doAssert testloop([0.MyInt, 1, 2, 3, 4, 5]) == 4

  # Initialize inputData using a runtime value `paramCount()`
  # so that compilers cannot optimize code using input data
  # that are known at compile time.
  var
    rand = (paramCount() or 123).initRand()
    inputData: seq[MyInt]

  for i in 0 .. (10000000 + paramCount()):
    inputData.add rand.rand(MyInt)

  var ret: MyInt
  bench:
    ret = testloop(inputData)
  # If output of `testloop` was not echoed, dead code elimination
  # would optimize out `testloop`.
  echo ret

Generated C code:

.. code-block:: c

  N_LIB_PRIVATE N_NIMCALL(NI, testloop__testwhileloop50faster_u10)(NI* arr_p0, NI arr_p0Len_0) {
    NI result;
    NI i;
  {	result = ((NI)(IL64(-9223372036854775807) - IL64(1)));
    {
      if (!(arr_p0Len_0 == ((NI)(IL64(-9223372036854775807) - IL64(1))))) goto LA3_;
      goto BeforeRet_;
    }
  LA3_: ;
    i = ((NI)0);
    {
      while (1) {
        NI TM__mpWMws40ADn9cAlaUZQotLg_2;
        NI TM__mpWMws40ADn9cAlaUZQotLg_3;
        if (nimSubInt(arr_p0Len_0, ((NI)1), &TM__mpWMws40ADn9cAlaUZQotLg_2)) { raiseOverflow(); goto BeforeRet_;
        };
        if (!(i < (NI)(TM__mpWMws40ADn9cAlaUZQotLg_2))) goto LA6;
        {
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          if (!(result < arr_p0[i])) goto LA9_;
          if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
          }
          result = arr_p0[i];
        }
  LA9_: ;
        if (nimAddInt(i, ((NI)2), &TM__mpWMws40ADn9cAlaUZQotLg_3)) { raiseOverflow(); goto BeforeRet_;
        };
        i = (NI)(TM__mpWMws40ADn9cAlaUZQotLg_3);
      } LA6: ;
    }
    {
      NIM_BOOL T13_;
      T13_ = (NIM_BOOL)0;
      T13_ = (i == (arr_p0Len_0-1));
      if (!(T13_)) goto LA14_;
      if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
      }
      T13_ = (result < arr_p0[i]);
  LA14_: ;
      if (!T13_) goto LA15_;
      if (i < 0 || i >= arr_p0Len_0){ raiseIndexError2(i,arr_p0Len_0-1); goto BeforeRet_;
      }
      result = arr_p0[i];
    }
  LA15_: ;
    }BeforeRet_: ;
    return result;
  }

In intermediate language tree, there is neither bound checks nor overflow checks inside the loop.
And `testloop` proc was divided to two functions. Second function checks `arr.len == MyInt.low` and if that was false, call first function that runs remaining code.
At the call site (it is not included in following code), first function is called and `if arr.len == MyInt.low:` is not executed.

.. code-block:: c

  NI testloop__testwhileloop50faster_u10.part.0 (NI * arr_p0, NI arr_p0Len_0)
  {
    NI result;
    NI i;
    long long int _6;
    sizetype _7;
    long long int _11;
    long int _20;
    long int _22;
    long long int _23;
    long long int _24;
    unsigned long _25;
    long unsigned int i.5_28;
    long unsigned int _29;
    NI * _30;
    long int _31;
    unsigned long _35;
    _Bool _36;
    long int _38;

    <bb 2> [local count: 113328220]:
    _11 = arr_p0Len_0_1(D) + -1;
    if (_11 <= 0)
      goto <bb 3>; [2.75%]
    else
      goto <bb 4>; [97.25%]

    <bb 3> [local count: 28715887]:
    # result_33 = PHI <_22(4), -9223372036854775808(2)>
    _36 = arr_p0Len_0_1(D) >= 0;
    _35 = (unsigned long) arr_p0Len_0_1(D);
    _25 = _35 >> 1;
    _24 = (long long int) _25;
    _23 = _24 * 2;
    i_10 = _36 ? _23 : 0;
    if (i_10 != _11)
      goto <bb 6>; [50.00%]
    else
      goto <bb 5>; [50.00%]

    <bb 4> [local count: 1015498035]:
    # i_13 = PHI <_6(4), 0(2)>
    # result_34 = PHI <_22(4), -9223372036854775808(2)>
    _7 = (sizetype) i_13;
    _20 = MEM[(NI *)arr_p0_18(D) + _7 * 8];
    _22 = MAX_EXPR <_20, result_34>;
    _6 = i_13 + 2;
    if (_6 >= _11)
      goto <bb 3>; [2.75%]
    else
      goto <bb 4>; [97.25%]

    <bb 5> [local count: 11451896]:
    i.5_28 = (long unsigned int) i_10;
    _29 = i.5_28 * 8;
    _30 = arr_p0_18(D) + _29;
    _31 = *_30;
    _38 = MAX_EXPR <_31, result_33>;

    <bb 6> [local count: 113328219]:
    # result_42 = PHI <_38(5), result_33(3)>
  LA15_:
  BeforeRet_:
    return result_42;

  }



  ;; Function testloop__testwhileloop50faster_u10 (testloop__testwhileloop50faster_u10, funcdef_no=15, decl_uid=3231, cgraph_uid=16, symbol_order=44)

  __attribute__((visibility ("hidden")))
  NI testloop__testwhileloop50faster_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    NI result;

    <bb 2> [local count: 114519220]:
    if (arr_p0Len_0_4(D) != -9223372036854775808)
      goto <bb 3>; [98.96%]
    else
      goto <bb 4>; [1.04%]

    <bb 3> [local count: 113328220]:
    result_2 = testloop__testwhileloop50faster_u10.part.0 (arr_p0_6(D), arr_p0Len_0_4(D)); [tail call]

    <bb 4> [local count: 114519219]:
    # result_3 = PHI <arr_p0Len_0_4(D)(2), result_2(3)>
  LA15_:
  BeforeRet_:
    return result_3;

  }

In generated assembly code, there is neither bound checks nor overflow checks inside the loop.
And `testloop` proc was divided to two functions.

.. code-block::

  testloop__testwhileloop50faster_u10.part.0:
    lea	r8, -1[rsi]
    mov	rcx, rdi
    movabs	rax, -9223372036854775808
    test	r8, r8
    jle	.L5
    lea	rdx, -2[rsi]
    shr	rdx
    and	edx, 1
    mov	rdi, rdx
    mov	rdx, QWORD PTR [rcx]
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	edx, 2
    cmp	rdx, r8
    jge	.L5
    test	rdi, rdi
    je	.L2
    mov	rdx, QWORD PTR [rcx+rdx*8]
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	edx, 4
    cmp	rdx, r8
    jge	.L5
    .p2align 4,,10
    .p2align 3
  .L2:
    mov	rdi, QWORD PTR [rcx+rdx*8]
    cmp	rax, rdi
    cmovl	rax, rdi
    mov	rdi, QWORD PTR 16[rcx+rdx*8]
    cmp	rax, rdi
    cmovl	rax, rdi
    add	rdx, 4
    cmp	rdx, r8
    jl	.L2
  .L5:
    mov	rdx, rsi
    and	rdx, -2
    test	rsi, rsi
    mov	esi, 0
    cmovs	rdx, rsi
    cmp	rdx, r8
    je	.L17
    ret
    .p2align 4,,10
    .p2align 3
  .L17:
  .L3:
  .L6:
    mov	rdx, QWORD PTR [rcx+r8*8]
    cmp	rax, rdx
    cmovl	rax, rdx
    ret
    .size	testloop__testwhileloop50faster_u10.part.0, .-testloop__testwhileloop50faster_u10.part.0
    .p2align 4
    .globl	testloop__testwhileloop50faster_u10
    .hidden	testloop__testwhileloop50faster_u10
    .type	testloop__testwhileloop50faster_u10, @function
  testloop__testwhileloop50faster_u10:
    endbr64
    movabs	rax, -9223372036854775808
    cmp	rsi, rax
    je	.L19
    jmp	testloop__testwhileloop50faster_u10.part.0
  .L19:
  .L20:
    mov	rax, rsi
    ret

When I compiled it with `-d:danger`, both generated intermediate language tree and assembly code were not the same as the one compiled with `-d:release`.
`testloop` proc was not divided to 2 functions and it was inlined at call site.
But the main loop in `testloop` were almost the same.

.. code-block:: c

  NI testloop__testwhileloop50faster_u10 (NI * arr_p0, NI arr_p0Len_0)
  {
    NI i;
    NI result;
    NI result;
    long int _8;
    long int _14;
    long int _16;
    long unsigned int i.2_18;
    long unsigned int _19;
    NI * _20;
    long int _21;
    sizetype _22;
    long int _23;
    long int _24;
    long int _29;
    unsigned long _33;
    unsigned long _34;
    unsigned long _35;

    <bb 2> [local count: 119352870]:
    if (arr_p0Len_0_3(D) != -9223372036854775808)
      goto <bb 3>; [98.96%]
    else
      goto <bb 8>; [1.04%]

    <bb 3> [local count: 118111600]:
    _8 = arr_p0Len_0_3(D) + -1;
    if (_8 <= 0)
      goto <bb 4>; [11.00%]
    else
      goto <bb 5>; [89.00%]

    <bb 4> [local count: 118111600]:
    # i_30 = PHI <i_36(6), 0(3)>
    # result_31 = PHI <_16(6), -9223372036854775808(3)>
    if (_8 != i_30)
      goto <bb 8>; [50.00%]
    else
      goto <bb 7>; [50.00%]

    <bb 5> [local count: 955630225]:
    # i_1 = PHI <i_17(5), 0(3)>
    # result_32 = PHI <_16(5), -9223372036854775808(3)>
    _22 = (sizetype) i_1;
    _14 = MEM[(NI *)arr_p0_4(D) + _22 * 8];
    _16 = MAX_EXPR <_14, result_32>;
    i_17 = i_1 + 2;
    if (_8 <= i_17)
      goto <bb 6>; [11.00%]
    else
      goto <bb 5>; [89.00%]

    <bb 6> [local count: 105119324]:
    _35 = (unsigned long) arr_p0Len_0_3(D);
    _34 = _35 + 18446744073709551614;
    _33 = _34 >> 1;
    _29 = (long int) _33;
    _24 = _29 + 1;
    i_36 = _24 * 2;
    goto <bb 4>; [100.00%]

    <bb 7> [local count: 59055800]:
    i.2_18 = (long unsigned int) i_30;
    _19 = i.2_18 * 8;
    _20 = arr_p0_4(D) + _19;
    _21 = *_20;
    _23 = MAX_EXPR <_21, result_31>;

    <bb 8> [local count: 119352870]:
    # result_2 = PHI <arr_p0Len_0_3(D)(2), _23(7), result_31(4)>
  LA15_:
  BeforeRet_:
    return result_2;

  }

.. code-block::

  testloop__testwhileloop50faster_u10:
    endbr64
    movabs	rax, -9223372036854775808
    cmp	rsi, rax
    je	.L7
    lea	r8, -1[rsi]
    test	r8, r8
    jle	.L18
    lea	rdx, -2[rsi]
    shr	rdx
    mov	rcx, rdx
    mov	rdx, QWORD PTR [rdi]
    and	ecx, 1
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	edx, 2
    cmp	r8, 2
    jle	.L19
    test	rcx, rcx
    je	.L3
    mov	rdx, QWORD PTR [rdi+rdx*8]
    cmp	rax, rdx
    cmovl	rax, rdx
    mov	edx, 4
    cmp	r8, 4
    jle	.L19
    .p2align 4,,10
    .p2align 3
  .L3:
    mov	rcx, QWORD PTR [rdi+rdx*8]
    cmp	rax, rcx
    cmovl	rax, rcx
    mov	rcx, QWORD PTR 16[rdi+rdx*8]
    cmp	rax, rcx
    cmovl	rax, rcx
    add	rdx, 4
    cmp	r8, rdx
    jg	.L3
  .L19:
    sub	rsi, 2
    shr	rsi
    lea	rdx, 2[rsi+rsi]
  .L5:
    cmp	r8, rdx
    je	.L22
    ret
    .p2align 4,,10
    .p2align 3
  .L22:
    mov	rdx, QWORD PTR [rdi+r8*8]
    cmp	rax, rdx
    cmovl	rax, rdx
    ret
    .p2align 4,,10
    .p2align 3
  .L18:
    xor	edx, edx
    jmp	.L5
  .L7:
  .L2:
  .L6:
    mov	rax, rsi
    ret

When I set `type MyInt = int32` in `testwhileloop2faster.nim` and compiled it with `-d:release` without `-march=native`, there are SSE instructions in generated assembly code.

.. code-block::

  testloop__testwhileloop50faster_u10.part.0:
    lea	r8, -1[rsi]
    mov	rcx, rdi
    mov	rdi, rsi
    test	r8, r8
    jle	.L16
    lea	rdx, -2[rsi]
    cmp	rdx, 7
    jbe	.L12
    shr	rdx, 3
    movdqa	xmm2, XMMWORD PTR .LC0[rip]
    mov	rax, rcx
    mov	rsi, rdx
    sal	rsi, 5
    add	rsi, rcx
    .p2align 4,,10
    .p2align 3
  .L9:
    movdqu	xmm0, XMMWORD PTR [rax]
    movdqu	xmm3, XMMWORD PTR 16[rax]
    add	rax, 32
    shufps	xmm0, xmm3, 136
    movdqa	xmm1, xmm0
    pcmpgtd	xmm1, xmm2
    pand	xmm0, xmm1
    pandn	xmm1, xmm2
    movdqa	xmm2, xmm1
    por	xmm2, xmm0
    cmp	rsi, rax
    jne	.L9
    movdqa	xmm0, xmm2
    sal	rdx, 3
    psrldq	xmm0, 8
    movdqa	xmm1, xmm0
    pcmpgtd	xmm1, xmm2
    pand	xmm0, xmm1
    pandn	xmm1, xmm2
    por	xmm1, xmm0
    movdqa	xmm2, xmm1
    psrldq	xmm2, 4
    movdqa	xmm0, xmm2
    pcmpgtd	xmm0, xmm1
    pand	xmm2, xmm0
    pandn	xmm0, xmm1
    por	xmm0, xmm2
    movd	eax, xmm0
  .L7:
    mov	r9d, DWORD PTR [rcx+rdx*4]
    lea	rsi, 0[0+rdx*4]
    cmp	eax, r9d
    cmovl	eax, r9d
    lea	r9, 2[rdx]
    cmp	r8, r9
    jle	.L2
    mov	r9d, DWORD PTR 8[rcx+rsi]
    cmp	eax, r9d
    cmovl	eax, r9d
    lea	r9, 4[rdx]
    cmp	r8, r9
    jle	.L2
    mov	r9d, DWORD PTR 16[rcx+rsi]
    cmp	eax, r9d
    cmovl	eax, r9d
    add	rdx, 6
    cmp	r8, rdx
    jle	.L2
    mov	edx, DWORD PTR 24[rcx+rsi]
    cmp	eax, edx
    cmovl	eax, edx
  .L2:
    mov	rdx, rdi
    xor	esi, esi
    and	rdx, -2
    test	rdi, rdi
    cmovs	rdx, rsi
    cmp	rdx, r8
    je	.L17
    ret
    .p2align 4,,10
    .p2align 3
  .L17:
  .L5:
  .L10:
    mov	edx, DWORD PTR [rcx+r8*4]
    cmp	eax, edx
    cmovl	eax, edx
    ret
    .p2align 4,,10
    .p2align 3
  .L12:
    mov	eax, -2147483648
    xor	edx, edx
    jmp	.L7
  .L16:
    mov	eax, -2147483648
    jmp	.L2
    .size	testloop__testwhileloop50faster_u10.part.0, .-testloop__testwhileloop50faster_u10.part.0
    .p2align 4
    .globl	testloop__testwhileloop50faster_u10
    .hidden	testloop__testwhileloop50faster_u10
    .type	testloop__testwhileloop50faster_u10, @function
  testloop__testwhileloop50faster_u10:
    endbr64
    movabs	rax, -9223372036854775808
    cmp	rsi, rax
    je	.L19
    jmp	testloop__testwhileloop50faster_u10.part.0
  .L19:
  .L20:
    mov	eax, -2147483648
    ret

I compiled `testwhileloop2faster.nim` with `type MyInt = int` and `type MyInt = int32` with different compile options and compared measured times.

======   ===============   =============   ====================
MyInt    GCC option        `-d:`           time (10^-3 second)
======   ===============   =============   ====================
int64    <empty>           `-d:release`    10.9
"        "                 `-d:danger`     10.9
"        `-march=native`   `-d:release`    10.9
"        "                 `-d:danger`     10.9
int32    <empty>           `-d:release`     4.78
"        "                 `-d:danger`      4.69
"        `-march=native`   `-d:release`     4.06
"        "                 `-d:danger`      4.04
======   ===============   =============   ====================

When `type MyInt = int`, `-d:release` and `-d:danger` builds are the same speed.
When `type MyInt = int32`, `-d:release` and `-d:danger` are almost the same speed.

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nimコンパイラが付け加える実行時チェックコードが最適化されるかどうか",
    description:"Nimコンパイラが付け加える実行時チェックコードが最適化されるかどうかについて解説します。",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"How Nim's runtime checks are optimized out",
    description:"Explains how runtime check code added by Nim compiler are optimized out",
    category:"Nim"))])
newArticle(articles, rstText)
