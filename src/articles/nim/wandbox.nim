const rstText = """
【
【ja:WandboxでNimを使う】
【en:Use Nim on oneline compiler: Wandbox】
】
======

【
【ja:`Wandbox`_ というOnline compilerについて紹介します。
Online compilerを使うとコンパイラ等をインストールしなくてもwebブラウザ上から `Nim`_ 言語を使うことができます。】
【en:I introduce online compiler: `Wandbox`_.
You can use `Nim`_ programming language on Web browser without installing Nim compiler.】
】

【
【ja:Wandboxでは最新のNimやnightly buildのNimが使える】
【en:Latest Nim and nightly build Nim are available on the Wandbox】
】
-----

【
【ja:`Wandbox`_ では最新のNimだけでなく古いバージョンも使うことができます。
Wandboxは定期的にGithubのdevelブランチの最新のNimのソースコードをダウンロードしてビルドしており、Nim HEADを選択すると使うことができます。
本当に最新のNimが使えているか確認するときはCompiler optionsに ``-v`` を入れて実行してみて下さい。
gitのcommitのhash値が表示されるので `Nim commits`_ からいつコミットされたものがビルドされているか確認できます。
また、Nim以外にも30種類以上のプログラミング言語を使うことができます。】
【en:Not only latest Nim, but also old Nims are available on `Wandbox`_.
Wandbox periodically download the source code of latest Nim on devel branch from Github and build it. You can use it when you choose Nim HEAD.
You can check whether it is the latest Nim version by adding ``-v`` to compiler options.
Then hash value of the git commit will be displayed and you can check which commit is used to build Nim HEAD from `Nim commits`_.
You can also use more than 30 programming languages. 】
】

【
【ja:コードを共有できる】
【en:You can share your code】
】
-----

【
【ja:Runした後にShareボタンが表示されるので、それをクリックすると共有可能なURLが表示されます。】
【en:Share button appears after clicking Run button. Then, permanent link will appears when you click the share button.】
】

【
【ja:プラグインを使うとVim/Emacs/xyzzyからWandboxが使える】
【en:There are plugins to use Wandbox on Vim/Emacs/xyzzy.】
】
-----

【
【ja:`Vim`_ に `wandbox-vim`_ プラグインをインストールし、
``:Wandbox --compiler=nim-head`` を実行するだけでカレントバッファのコードがwandboxで実行され結果がVimに表示されます。
このようなプラグインはwandboxの `API`_ を使ってコードの送信と結果の受信を行っています。】
【en:Just install `wandbox-vim`_ plugin to your `Vim`_.
Then, code in the curret buffer is executed on wandbox and the result is displayed when you execute ``:Wandbox --compiler=nim-head``.
Plugins for wandbox use wandbox `API`_ to send code and receive result.】
】

【
【ja:複数のファイルを作れる】
【en:Multiple text files】
】
-----
【
【ja:Wandboxで＋ボタンを押すと新しいファイルを追加できます。
そのファイルはmoduleとしてimportしたり、実行時/コンパイル時にテキストファイルとして読み込むことができます。】
【en:You can add a new file when you click + button above editor.
You can import that file as module or read it as text file at compile time or runtime.】
】

【
【ja:Wandboxはオープンソース】
【en:Wandbox is open source】
】
-----

【
【ja:https://github.com/melpon/wandbox にWandboxのリポジトリがあります。
`Wandbox Builder`_ のリポジトリにはWandboxにコンパイラをインストールするスクリプトがあります。
もしNimのバージョンが更新されていなかったり、正しくビルド、インストールされていないときはそこにあるスクリプトを修正してPull Requestを送ります。
新しいバージョンのコンパイラや新しい言語を追加したい場合もこのリポジトリにファイルを追加/修正してPull Requestを送ります。
Nim関係のスクリプトは `build/nim-head`_ と `build/nim`_ ディレクトリにあります。】
【en:https://github.com/melpon/wandbox is the repository of Wandbox.
There are scripts to build and install compilers to Wandbox in `Wandbox Builder`_ repository.
If you found Nim was not updated or not correctly built or installed, fix scripts in that repository and send Pull request. 
When you want to add a new version compiler or new language, edit or add scripts and send Pull request.
Scripts related to Nim can be found at `build/nim-head`_ and `build/nim`_ directory.】
】


.. _Wandbox: https://wandbox.org/
.. _Nim: https://nim-lang.org/
.. _Nim commits: https://github.com/nim-lang/Nim/commits/devel
.. _Vim: https://www.vim.org/
.. _wandbox-vim: https://github.com/rhysd/wandbox-vim
.. _API: https://github.com/melpon/wandbox/blob/master/kennel2/API.rst
.. _Wandbox Builder: https://github.com/melpon/wandbox-builder
.. _build/nim-head: https://github.com/melpon/wandbox-builder/tree/master/build/nim-head
.. _build/nim: https://github.com/melpon/wandbox-builder/tree/master/build/nim
"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"WandboxでNimを使う",
    description:"Nim言語をWandboxから使うには")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Use Nim on oneline compiler: Wandbox",
    description:""))])
newArticle(articles, rstText)
