const rstText = """
# 【
【ja:Google ColaboratoryでNimを使う】
【en:Use Nim on Google Colaboratory】
】

【
【ja:】
【en:】
】

【
【ja:
`こちらにGoogle Colaboratoryに関する記事もあります。 <google_colab.ja.html>`_

`Nim4Colab`_ 拡張を使うと `Google Colaboratory`_ 上で `Nim`_ 言語を使うことができます。
】
【en:
`Article about Google Colaboratory <google_colab.en.html>`_

You can use `Nim`_ language on `Google Colaboratory`_ by using `Nim4Colab`_ extension.
】
】

## 【
【ja:使い方】
【en:How to use】
】

【
【ja:
以下のコードを `Google Colaboratory`_ のセルにコピペして実行してください。
`Nim4Colab`_ 拡張のダウンロード、インストールと読み込みを行います。
】
【en:
Copy and paste following code to a cell on `Google Colaboratory`_ and run.
This code download, install and load `Nim4Colab`_ extension.
】
】
.. code::

  !pip install git+https://github.com/demotomohiro/nim4colab.git
  %load_ext nim4colab

【
【ja:
その後は以下のように ``%%nimc`` の下にNimのコードを書くことで実行できるようになります。
】
【en:
Then, you can run Nim code by writing your code under ``%%nimc``.
】
】

.. code::

  %%nimc
  echo NimVersion

## 【
【ja:サンプルコード】
【en:Sample Codes】
】

`【
【ja:簡単なサンプル】
【en:Basic】
】 <https://colab.research.google.com/drive/1aNmsJmgnxz-4yr1hT0ZdHh9-XQ_8dcRk>`_

`【
【ja:PNG画像を作るサンプル】
【en:Make PNG image】
】 <https://colab.research.google.com/drive/15w2dtk9QE8QDTsqMeRnWCzR7f2kSseoq>`_

`【
【ja:EGLとOpenGLを使うサンプル】
【en:Make animation PNG using EGL & OpenGL】
】 <https://colab.research.google.com/drive/1J0B0qVvovrJZJI1OU75jIMUjWnymi_6G>`_


## 【
【ja:行番号を表示する】
【en:Show line numbers】
】

【
【ja:
Nimから出力されるコンパイルエラーには行番号が含まれています。
エラーのあった場所の行がどこか簡単に見つけられるように行番号を表示します。
メニューの"ツール"→"設定..."をクリックして設定画面を表示し、"行番号を表示"にチェックします。
】
【en:
Nim prints error messages with line numbers.
This is how to show line numbers on editor so that you can find a line that cause the error.
In menu, click "Tools" -> "Preferences..." and check "Show line numbers".
】
】

## 【
【ja:仕組み】
【en:How it work】
】

【
【ja:
初めて `Nim4Colab`_ のコマンドを実行したときに自動的に `Nim nightlies`_ から最新版の `Nim`_ をダウンロードしインストールします。
ユーザのコードは ``~/code.nim`` に書き込まれ ``nim`` コマンドが呼ばれます。
】
【en:
`Nim4Colab`_ downloads and installs latest `Nim`_ from `Nim nightlies`_ when first time one of `Nim4Colab`_ command is called.
User code is saved to ``~/code.nim`` file and ``nim`` command is called.
】
】

## 【
【ja:関連記事】
【en:Related articles】
】

【
【ja:SSHやVNC経由でNimをGoogle Colaboratoryの仮想マシン上で使いたい人には参考になるかもしれません。】
【en:If you want to use Nim on Google Colaboratory's virtual machine via SSH or VNC:】
】

【
【ja:`sshでGoogle Colaboratoryを使う <ssh.ja.html>`_】
【en:`How to access Google Colaboratory using ssh <ssh.en.html>`_】
】

【
【ja:`Google ColaboratoryでOpenGLを使ったデスクトッププログラムを動かす <vnc.ja.html>`_】
【en:`How to run OpenGL desktop programs on Google Colaboratory <vnc.en.html>`_】
】

.. _Nim4Colab: https://github.com/demotomohiro/nim4colab
.. _Google Colaboratory: https://colab.research.google.com/
.. _Nim: https://nim-lang.org/
.. _Nim nightlies: https://github.com/nim-lang/nightlies

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Nim4Colabを使ってGoogle ColaboratoryでNim言語を使う",
    description:"Nim4Colab拡張を使ってGoogle ColaboratoryでNim言語を利用する方法を紹介します",
    category:"Google Colaboratory")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Use Nim on Google Colaboratory by using Nim4Colab",
    description:"Explains how to use Nim language on Google Colaboratory by using Nim4Colab extension",
    category:"Google Colaboratory"))])
newArticle(articles, rstText)
