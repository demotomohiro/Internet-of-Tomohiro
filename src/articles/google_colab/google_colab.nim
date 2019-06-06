const rstText = """
【
【ja:Google Colaboratoryについて】
【en:About Google Colaboratory】
】
======

【
【ja:
Python用の無料で使えるオンラインコンパイラのようなものです。Web上でPythonコードを書いて実行すると実行結果が表示されます。

- コードと実行結果は一つのファイルとしてGoogleドライブに保存
- ユーザ毎に仮想マシンが割り当てられてその上でコード実行
- OSはubuntu
- 入力したコードはrootユーザとして実行
- 仮想マシンはインターネットに繋がっている
- apt-get/git/wget等のコマンドを使って好きなプログラムやライブラリをインストールすることが可能
- 一定時間何もしないと仮想マシンはリセットされ、ストレージが初期化される
  - 大事なデータは要バックアップ
  - ライブラリをインストールして使う場合は毎日インストールし直すことになるので、インストールするコマンドもコードと一緒に保存しておくとよい
- NVIDIA Tesla T4というGPUが使える
  - CUDAやOpenGL等を使うことができる
】
【en:
It is like online compiler for Python language. You write python code, run it and get output.

- Code and outputs are stored in Google drive as a colaboratory notebook
- Your code is executed on a virtual machine that assigned to you
- Ubuntu is installed
- Your code is executed as root user
- The virtual machine can connect to internet
- You can install any program or library using apt-get, git or wget.
- When idle for a while, the virtual machine is reset and the storage is initialized.
  - You need to backup important data on the storage.
  - If you install and use a library, you need to install them everydays. So you would better to save commands to install the library with your code.
- GPU (NVIDIA Tesla T4) is available
  - You can use CUDA or OpenGL.
】
】

【
【ja:詳しくは以下のページを読んでください。】
【en:For more info:】
】

https://research.google.com/colaboratory/faq.html

【
【ja:
``!`` から始まる行はBashコマンドとして実行されます。 ``!ls`` を実行するとカレントディレクトリの内容が表示されます。
このコマンドもrootユーザとして実行されるので ``su`` や ``sudo`` を使う必要はありません。
もし重要なファイルを壊しても仮想マシンをリセットして初期状態に戻すことができます。
】
【en:
Any input line beginning with a ``!`` is executed as Bash command.
For example, ``!ls`` displays a content of a current directory.
Because this command is also executed as root user, you don't need to use ``su`` or ``sudo`` commands.
When you accidentally broke important files, you can reset virtual machine and restore storage.
】
】

【
【ja:詳しくは以下のページを読んでください。】
【en:For more info:】
】

https://ipython.readthedocs.io/en/stable/interactive/reference.html#system-shell-access
https://ipython.readthedocs.io/en/stable/interactive/shell.html

【
【ja:GPUを有効にする方法】
【en:How to enable GPU】
】
-----

【
【ja:
メニューの"ランタイム"→"ラインタイムのタイプの変更"→"ノートブックの設定"の"ハードウェアアクセラレータ"をGPUに設定します。
GPUが有効になっていれば ``!nvidia-smi`` コマンドを実行すると以下のようなメッセージが表示されます。
】
【en:
On menu, "Runtime" -> "Change runtime type" -> Set "Hardware accelerator" to GPU.
If GPU was available, ``!nvidia-smi`` command print following message:
】
】

.. code::

  +-----------------------------------------------------------------------------+
  | NVIDIA-SMI 418.67       Driver Version: 410.79       CUDA Version: 10.0     |
  |-------------------------------+----------------------+----------------------+
  | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
  | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
  |===============================+======================+======================|
  |   0  Tesla T4            Off  | 00000000:00:04.0 Off |                    0 |
  | N/A   64C    P8    17W /  70W |      0MiB / 15079MiB |      0%      Default |
  +-------------------------------+----------------------+----------------------+
                                                                                 
  +-----------------------------------------------------------------------------+
  | Processes:                                                       GPU Memory |
  |  GPU       PID   Type   Process name                             Usage      |
  |=============================================================================|
  |  No running processes found                                                 |
  +-----------------------------------------------------------------------------+


【
【ja:Vimキーバインドを有効にするプラグイン】
【en:Enable Vim key bind plugin】
】
-----

【
【ja:
AutovimというChrome用プラグインをインストールするとVimのようにコードを入力できるようになります。
】
【en:
Autovim Chrome plugin enable vim mode in Google colaboratory.
】
】

https://chrome.google.com/webstore/detail/autovim/licohjbphilmljmjonhiifkldfahnmja?authUser=0&hl=en-US
https://github.com/thomcom/autovim

【
【ja:関連記事:】
【en:Related articles:】
】
-----

【
【ja:`sshでGoogle Colaboratoryを使う <ssh.ja.html>`_】
【en:`How to access Google Colaboratory using ssh <ssh.en.html>`_】
】

【
【ja:本物のVimやNeovimが使えます!】
【en:You can use real Vim/Neovim!】
】

【
【ja:`Google ColaboratoryでOpenGLを使ったデスクトッププログラムを動かす <vnc.ja.html>`_】
【en:`How to run OpenGL desktop programs on Google Colaboratory <vnc.en.html>`_】
】

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Google Colaboratoryについて",
    description:"Google Colaboratoryについて簡単に説明します。")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"About Google Colaboratory",
    description:"Explains about Google Colaboratory"))])
newArticle(articles, rstText)
