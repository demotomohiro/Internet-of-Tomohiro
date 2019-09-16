const rstText = """
【
【ja:sshでGoogle Colaboratoryを使う】
【en:How to access Google Colaboratory using ssh】
】
======

【
【ja:`VNCを使ってGoogle Colaboratory上のデスクトップ環境を使うこともできます。 <vnc.ja.html>`_】
【en:`You can also use desktop environment on Google Colaboratory using VNC. <vnc.en.html>`_】
】

【
【ja:必要なもの】
【en:Requirements】
】
-----


【
【ja:- パソコンまたはAndroidスマートフォン】
【en:- PC or Android smartphone】
】

【
【ja:- Googleアカウント】
【en:- Google account】
】

【
【ja:- `Google Colaboratory`_ が使えるブラウザ】
【en:- Browser that `Google Colaboratory`_ works】
】

【
【ja:- sshクライアント
   Windowsを使う場合は `scoop`_ を使うと簡単にopensshをインストールできます。
   Androidスマートフォンを使う場合は `JuiceSSH`_ が使えます。
】
【en:- ssh client
   If you use Windows, you can install openssh with `scoop`_ . 
   If you use Android smartphone, you can use `JuiceSSH`_ .
】
】


【
【ja:手順】
【en:Procedure】
】
-----

【
【ja:1. `ngrok`_ にサインアップ

   - 無料のプランでかまいません。
     `ngrok`_ にサインアップしたくない場合は以下のリンクに `Serveo`_ を使ったバージョンもあります。
     しかし `ngrok`_ より遅くなります。
】
【en:1. Sign up for `ngrok`_

   - You don't need to buy paid plans.
     If you don't want to sign up for anything, there is `Serveo`_ version in following link.
     But it is slower than `ngrok`_ version.
】
】
     https://github.com/demotomohiro/Google-Colaboratory-SSH-samples/blob/master/src/ssh_serveo.ipynb
【
【ja:2. コードをセルへコピペする

   - Colaboratoryでセルに以下のコードをコピペします。
】
【en:2. Copy & paste setup code

   - Copy & paste one of following code to the cell in Colaboratory.
】
】
【
【ja:     - SSHのみの場合】
【en:     - SSH only】
】
     .. code::

        !pip install git+https://github.com/demotomohiro/remocolab.git
        import remocolab
        remocolab.setupSSHD()

【
【ja:     - SSHとVNCを使う場合】
【en:     - SSH and VNC】
】
     .. code::

        !pip install git+https://github.com/demotomohiro/remocolab.git
        import remocolab
        remocolab.setupVNC()

【
【ja:3. 左上の再生ボタンのようなところをクリック】
【en:3. Click run bottom in top left】
】

   .. image:: https://user-images.githubusercontent.com/1882512/64982179-12ed6380-d8ad-11e9-8f1a-acb5d34d0ab4.png

【
【ja:4. ngrokのauthtokenをコピペする

   ngrokのauthtokenをコピペするようメッセージが表示されるのでngrokにログインして左のメニューからAuthをクリックし、Copyをクリックし、Google Colaboratoryの画面に戻ってペーストしてエンターキーを押して下さい。
】
【en:4. Copy ngrok authtoken

   - After the message that ask you to copy ngrok authtoken displayed, login to ngrok, click Auth on left side menu, click Copy, return to Google Colaboratory, paste it and push enter key.
】
】
   .. image:: https://user-images.githubusercontent.com/1882512/64982180-12ed6380-d8ad-11e9-9db0-71854fb66d0b.png
【
【ja:5. ngrok regionを訊かれるので自分に一番近い場所を選んで入力

   今日本にいるならjpと入力してエンターキーを押します。
】
【en:5. Select ngrok region

   Probably the region closest to you is fastest.
】
】
【
【ja:6. SSHサーバ立ち上がるまで待つ

   - OpenSSHサーバのインストールやSSHサーバに接続できるようにするための処理が行われます。
   - 自動的に ``colab`` という名前のアカウントを作成され、しばらくするとコードの下のほうに ``root`` と ``colab`` ユーザのパスワードが表示されます。このパスワードはこのコードが実行される度にランダムに生成されます。
】
【en:6. Wait for starting SSH server

   - It install OpenSSH server and configure the server for login from your machine.
   - User account called ``colab`` will be created and passwords for ``root`` and ``colab`` user will be displayed under that code. These passwords are randomly generated everytime you run this code.
】
】
【
【ja:7. サーバにログイン
   - セットアップが完了するとsshコマンドが表示されるのでそれを自分のPCのコマンドラインにコピペして実行します。
】
【en:7. Login to the server
  - After setup completed, SSH command to login to the server is displayed. Copy it to your terminal and execute it.
】
】


【
【ja:仕組み】
【en:How it works】
】
-----

【
【ja:`Google Colaboratory`_ ではpythonのコードだけでなく先頭に!をつけることでbashコマンドも実行することができます。
コマンドはrootユーザとして実行されるので ``apt`` や ``pip`` でパッケージを追加したり ``wget`` でどこかからファイルをダウンロードして実行することもできます。
なので簡単にopensshをインストールしてsshdを起動することができます。
sshdを普通に実行しただけではインターネット経由でログインすることはできないのでngrokを使ってログインできるようにしています。
しかしsshでのアクセスが常にngrokのサーバを経由するため遅延が大きくなります。
】
【en:You can run not only python code but also bash commands on `Google Colaboratory`_.
These commands are executed as root. You can install any packages with ``apt`` or ``pip``.
And you can even download any file with ``wget`` and run it.
So you can easily install openssh and run sshd.
It use ngrok so that you can login to the ssh server because you cannot login to it through the internet just by running sshd.
But there are large latency because all communication between the server and the client go through the ngrok server.
】
】


【
【ja:【【おまけ】】Nimをインストールして使ってみる】
【en:【【Optional】】Install Nim】
】
-----

【
【ja:Pythonよりも使いやすくて高速な `Nim`_ 言語をインストールしてみます。
以下のコマンドを実行します。
】
【en:Install `Nim`_ language that is faster and more elegant than python.
Execute following command:
】
】

.. code::

  $$ curl https://nim-lang.org/choosenim/init.sh -sSf | sh


【
【ja:インストールが終わると】
【en:After installing you asked to copy 】
】

.. code::

  export PATH=/home/colab/.nimble/bin:$$PATH

【
【ja:を ``~/.bashrc`` に追加するよう言われるのでそうします。】
【en:to ``~/.bashrc`` .】
】

【
【ja:以下のようにNimが使えるようになります。】
【en:Then you can use Nim. yay!】
】

.. code::

  $$ echo "echo \"Hello Nim!\"" > hello.nim
  $$ nim c -r hello.nim

.. _Google Colaboratory: https://colab.research.google.com/
.. _Scoop: https://scoop.sh/
.. _ngrok: https://ngrok.com/ 
.. _Serveo: https://serveo.net/
.. _Nim: https://nim-lang.org/
.. _JuiceSSH: https://juicessh.com/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"sshでGoogle Colaboratoryを使う",
    description:"Google Colaboratory上にsshサーバを稼働させてssh経由で利用する方法を紹介します")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"How to access Google Colaboratory using ssh",
    description:"Explains how to run ssh server on Google Colaboratory and use it via ssh"))])
newArticle(articles, rstText)
