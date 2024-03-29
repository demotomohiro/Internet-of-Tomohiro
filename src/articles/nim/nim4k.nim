const rstText = """
# 【
【ja:Nim言語で4k introを作る方法】
【en:How to make 4k intro with Nim programming language】
】

【
【ja:`Nim`_ 言語で4k introを作るサンプルを作りました。】
【en:I made 4k intro samples using `Nim`_ programming language.】
】

https://github.com/demotomohiro/nim-4k-intro-sample

## 【
【ja:4k introとは】
【en:What is 4k intro?】
】

【
【ja:
簡単に言うと4096バイト以下のサイズでかっこいい映像と音楽を作るプログラムのことです。
Demoscene文化の中の一つに4k introという一つのジャンルがあります。
Demosceneについて知るには以下の動画を観るとよいでしょう。
】
【en:
It is a program less than or equal to 4096 bytes and play cool visual and music.
It is a part of demoscene culture.
This is a good video to understand what is demoscene.
】
】
https://www.youtube.com/watch?v=iRkZcTg1JWU


- 【 【ja:最近開催された】【en:List of prods released at 】 】 `Revision 2020<https://2020.revision-party.net>`_ 【 【ja:の参加作品の一覧】 【en:】 】:
https://www.pouet.net/party.php?which=1550&when=2020


## 【
【ja:MS Windowsでサイズが小さい実行ファイルを作る方法】
【en:How to make a small size executable on MS Windows】
】

- 【
【ja:大きなデータを使わない】
【en:Don't use large data】
】

  【
  【ja:
  4k introは実行ファイル単体で動作しなければなりません。画像ファイルや音楽ファイルなどを読み込んではいけません。
  インターネットからデータをダウンロードすることもできません。
  かっこいい映像を作るために大きなテクスチャ画像や3Dモデルを使っていては実行ファイルのサイズを小さくすることはできません。
  なんとか工夫して小さくするか、プロシージャルな方法を使ってデータを生成する必要があります。
  フラクタルなどを使えば小さなコードから複雑な映像を作ることができますが、4k introを見ている人達は有名なフラクタルは何度も観ていて飽き飽きしています。
  以下のサイトには4k intro作成に使えそうな技術の解説があります。
  】
  【en:
  4k intro must runs alone and may not load image files or music files.
  It may not download data from the internet.
  If you use large texture image or 3D model to create cool scene, you cannot make a small size executable.
  You have to make them small or generate them procedurally.
  For example, you can make nice scene with small code using fractal.
  But people watching 4k intro have seen enough of fractals.
  You can learn graphics that can be used in 4k intro in following web site:
  】
  】
  - http://www.iquilezles.org/

  【
  【ja:このサイトで参考になりそうなGLSLコードに出会えるかもしれません。】
  【en:You might found a GLSL code that can be used in your 4k intro:】
  】
  - https://www.shadertoy.com/

- 【
【ja:C標準ライブラリを使わない】
【en:Don't use standard C library】
】

  【
  【ja:C言語の標準ライブラリの機能を使うと標準ライブラリがリンクされて実行ファイルのサイズが4096バイトを超えてしまいます。
  標準ライブラリをリンクしないようにコンパイルオプションを指定し、必要な機能は自分で実装するかwindowsAPIや `OpenGL`_ を直接呼び出して実装します。
  `Nim`_ 言語の標準ライブラリでC言語の標準ライブラリを呼び出しているものは使いません。
  Visual C++で標準ライブラリを使わないときは最初に呼ばれる関数の名前がデフォルトで `WinMainCRTStartup` になります。
  】
  【en:If you link standard C library to your executable, size of it exceeds 4096 bytes.
  You need to specify some compile/link options to avoid linking C standard library.
  And you need to implement all functions yourself or directly use windowsAPI or `OpenGL`_.
  You cannot use `Nim`_ procedures that is implemented with functions in standard C library.
  In visual C++, `WinMainCRTStartup` is a default name of entry point function when standard library is not linked.
  】
  】

- 【
【ja:Crinklerで実行ファイルを圧縮する】
【en:Compress executable file with Crinkler】
】

  【
  【ja:
  `Crinkler`_ はリンカのようにC/C++コンパイラから生成されたオブジェクトファイルをまとめて実行ファイルをつくります。このときにコードとデータを圧縮しそれらを解凍するコードを付加します。
  この実行ファイルは実行時にそれらを解凍してメモリに書き込んでから実行します。
  ランダムに近いデータは圧縮したときに小さくなりにくく、規則があったり同じパターンが繰り返し現れるようなデータは小さくなりやすいです。
  圧縮される前のコードとデータをできるだけ小さくするよりも、多少大きくなっても同じビット列が何度もでてくるようにしたほうが圧縮後のサイズが小さくなりやすいです。
  なので関数を展開するとより小さい実行ファイルになることがよくあります。
  】
  【en:
  `Crinkler`_ link object files generated by C/C++ compiler to make an executable file like a linker.
  It compress code and data when it makes executable file and add a code to decompress them.
  That executable decompress the content, writes them to memory and executes it. 
  Data that have some pattern can be compressed to smaller, but random data are hardly compressed to smaller.
  So larger data that have many same bit patterns can be compressed to smaller size rather than smaller but random data.
  Inlining procedures usually make smaller executable files.
  】
  】

- 【
【ja:後片付けしない】
【en:Dont clean up】
】

  【
  【ja:
  ヒープメモリやOpenGLのバッファオブジェクトなどの作ったら後で解放しろと言われるものは4k introでは解放する必要はありません。
  そういったコードを書くだけ無駄に実行ファイルが大きくなるだけです。
  自分で解放しなくてもプログラムが終了したときにOSが片づけてくれるはずです。
  4k introはせいぜい数分間しか動かないので、ループ内でリソースを作り続けたりしない限りは解放しなくても問題ありません。
  4k introが実行時に何をするかはほぼコンパイル時に決まるのでヒープメモリを使う必要性はほぼ無いと思います。
  WindowsでC標準ライブラリを使わない場合は `ExitProcess` というwindowsAPIを呼ばないとプロセスを完全に終了できません。
  】
  【en:
  You don't need to clean up resources like heap memory or buffer objects in OpenGL.
  Clean up code just make a executable file bigger.
  Resources you used are clean up by OS when the process is terminated.
  As long as you don't allocate a resource inside main loop, it doesn't cause any problems because 4k intro runs only for a few minutes.
  Most of 4k intros don't need to use heap memory because what they do at runtime is usually determined at compile time.
  On windows, in case C standard library is not used, windowsAPI called `ExitProcess` must be called to terminate the process.
  】
  】
  - https://stackoverflow.com/questions/44488392/c-windows-return-vs-exitprocess

- 【
【ja:GLSLコードを小さくする】
【en:Minimize GLSL code】
】

  【
  【ja:
  `OpenGL`_ を使う場合はGLSLで書かれたコードをプログラムの中に埋め込むことになります。
  `Shader_Minifier`_ はGLSLコードの空文字を削除したり変数名や関数名を小さくしたりなどして小さくしてくれます。
  】
  【en:
  In case your 4k intro uses `OpenGL`_, GLSL code is embedded to an executable file.
  `Shader_Minifier`_ minify your GLSL code by removing white spaces, replacing variable and function name to smaller one and etc.
  】
  】

- 【
【ja:その他】
【en:other tips】
】

  【
  【ja:
  - 画面サイズをconst値にして画面の解像度別に実行ファイルを作ります。
  - デバッグビルドではデバッグしやすいようにC言語の標準ライブラリをリンクし、速くビルドできるように `Crinkler`_ を使いません。
  - `Crinkler`_ に/REPORT:repo.htmlオプションを渡すと実行ファイル内のコードやデータサイズの内訳を見ることができます。
  】
  【en:
  - Declare screen size as const and make executables for each screen size.
  - In debug build, link C standard library for easy debug and build it without Crinkler in order to build faster.
  - You can see each size of code and data in your executable file by passing /REPORT:repo.html option to `Crinkler`_.
  】
  】

## 【
【ja:Nim言語を使うメリット】
【en:Why use Nim programming language】
】

- 【
【ja:余計な';'や'{', '}'のような文字がソースコード上に現れないので読みやすい】
【en:Easy to read source code because there is no visual noise charactors like ';', '{' or '}'】
】
- 【
【ja:コンパイル時に動くコードを簡単に書ける
】
【en:Easy to write a code that is executed at compile time】
】

  - 【
  【ja:コンパイル時でも実行時と同じように文字列操作を行える】
  【en:string can be manipulated at compile time in the same way as at runtime code】
  】
  - `staticRead<https://nim-lang.org/docs/system.html#staticRead%2Cstring>`_ 【
  【ja:はコンパイル時にファイルを読み込んでその内容をstring値として返す】
  【en:reads file and return the content as string value】
  】
  - `staticExec<https://nim-lang.org/docs/system.html#staticExec%2Cstring%2Cstring%2Cstring>`_ 【
  【ja:はコンパイル時に指定されたコマンドを実行してその標準出力をstring値として返す】
  【en:executes an external process at compile-time and returns its text output (stdout + stderr)】
  】

- 【
【ja:テンプレートやマクロなどのメタプログラミング機能が優れている】
【en:Nim has great meta programming feature like template or macro】
】
  - https://nim-lang.org/docs/manual.html#templates
  - https://nim-lang.org/docs/manual.html#macros
- 【
【ja:`OpenGL`_ の拡張機能を使うときに実際にコード内で使われている拡張機能のみが初期化される】
【en:Only `OpenGL`_ extension functions that are used in code are initialized】
】
- 【
【ja:Nim言語はC言語に変換してからCコンパイラを呼び出して実行ファイルを作るのでC言語用のライブラリやツールを使える】
【en:Nim can use libraries and tools for C programming language because it makes an executable file by generating C code and calling C compiler.】
】
- 【
【ja:ビルド設定をNim言語に近いNimScriptで記述できる】
【en:NimScript can be used to write a configuration file and a build tool】
】
  - https://nim-lang.org/docs/nims.html

.. _Nim: https://nim-lang.org/
.. _OpenGL: https://www.opengl.org/
.. _Crinkler: http://crinkler.net/
.. _Shader_Minifier: https://github.com/laurentlb/Shader_Minifier
"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim言語で4k introを作る方法",
    description:"Nim言語を使って4k introのような小さな実行ファイルを作る方法を解説します",
    category:"Nim")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"How to make 4k intro with Nim programming language",
    description:"Explains how to make a small executable file like 4k intro with Nim programming language",
    category:"Nim"))])
newArticle(articles, rstText)
