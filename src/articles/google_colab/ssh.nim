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
     `ngrok`_ にサインアップしたくない場合は `Serveo`_ を使ったバージョンもあります。
     次のステップで ``ssh_ngrok.ipynb`` の代わりに ``ssh_serveo.ipynb`` を使って下さい。
     しかし `ngrok`_ より遅くなります。
】
【en:1. Sign up for `ngrok`_

   - You don't need to buy paid plans.
     If you don't want to sign up for anything, there is `Serveo`_ version.
     Use ``ssh_serveo.ipynb`` instead of ``ssh_ngrok.ipynb`` in next step.
     But it is slower than `ngrok`_ version.
】
】
【
【ja:2. ssh_ngrok.ipynbをGoogleドライブへコピーする

   - `Google Colaboratory SSH samples`_ の ``src`` ディレクトリから ``ssh_ngrok.ipynb`` をダウンロードして自分のGoogleドライブへコピーし、Colaboratoryで開きます。
】
【en:2. Copy ssh_ngrok.ipynb to your Google drive

   - Download ``ssh_ngrok.ipynb`` from ``src`` directory of `Google Colaboratory SSH samples`_, copy it to your Google drive and open it with Colaboratory.
】
】
【
【ja:3. 左上の再生ボタンのようなところをクリック

   自動的に ``colab`` という名前のアカウントを作成され、しばらくするとコードの下のほうに ``root`` と ``colab`` ユーザのパスワードが表示されます。
   このパスワードはこのコードが実行される度にランダムに生成されます。
】
【en:3. Click run bottom in top left

   - User account called ``colab`` will be created and passwords for ``root`` and ``colab`` user will be displayed under that code.
     These passwords are randomly generated everytime you run this code.
】
】
   .. image:: https://user-images.githubusercontent.com/1882512/55267426-651dd680-52c5-11e9-80d3-7e418a46e4b2.png
【
【ja:4. ngrokのauthtokenをコピペする

   ngrokのauthtokenをコピペするようメッセージが表示されるのでngrokにログインして左のメニューからAuthをクリックし、Copyをクリックし、Google Colaboratoryの画面に戻ってペーストしてエンターキーを押して下さい。
】
【en:4. Copy ngrok authtoken

   - After the message that ask you to copy ngrok authtoken displayed, login to ngrok, click Auth on left side menu, click Copy, return to Google Colaboratory, paste it and push enter key.
】
】
   .. image:: https://user-images.githubusercontent.com/1882512/55278529-c2ab3500-5350-11e9-81ef-8bae46b2c21a.png
【
【ja:5. ngrok regionを訊かれるので自分に一番近い場所を選んで入力

   日本からだとap - Asia/Pacificよりus - United Statesを選んだほうが速いようです。
】
【en:5. Select ngrok region

   Probably the region closest to you is fastest.
】
】
【
【ja:6. sshコマンドが表示されるのでそれをコマンドラインにコピペして実行】
【en:6. Copy ssh command to your terminal and execute it】
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
.. _Google Colaboratory SSH samples: https://github.com/demotomohiro/Google-Colaboratory-SSH-samples
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
