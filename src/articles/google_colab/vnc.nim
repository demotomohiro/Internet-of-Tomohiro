const rstText = """
【
【ja:【【素でタダ】】Google ColaboratoryでOpenGLを使ったデスクトッププログラムを動かす【【STADIAモドキ】】】
【en:How to run OpenGL desktop programs on Google Colaboratory】
】
======

.. figure:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_unigine_valley_cap.png
   :width: 100%

   【
   【ja:Unigine ValleyをGoogle Colaboratoryで動かしているところ】
   【en:Unigine Valley Running on Google Colaboratory】
   】

.. contents::

【
【ja:必要なもの】
【en:Requirements】
】
-----

【
【ja:`Google Colaboratory`_ 上のデスクトップ環境にアクセスするには `ngrok`_ または `Argo Tunnel`_ のどちらかを使う必要があります。
- ngrok
  - ngrokにサインアップする必要がある
  - 特定のソフトウェアを自分のマシンにインストールする必要がない
  - remocolabを実行するたびにauthtokenをコピペする必要がある

- Argo Tunnel
  - アカウントを作る必要がない。`無料バージョンはアカウント不要。 <https://blog.cloudflare.com/a-free-argo-tunnel-for-your-next-project/>`_
  - `cloudflared`_ を自分のマシンにダウンロードする必要がある
  - Argo TunnelはArgo Smart Routing技術を使って自動的に最適な通信経路を見つけるらしいのでサーバの地域を指定できない。
】
【en:You need to use `ngrok`_ or `Argo Tunnel`_ to access desktop environment on `Google Colaboratory`_.
- ngrok
  - You need to sign up for ngrok
  - You don't need to install specific software on client machine
  - You need to copy and paste authtoken to colab everytime you run remocolab

- Argo Tunnel
  - You don't need to create account. `Cloudflare provide free version <https://blog.cloudflare.com/a-free-argo-tunnel-for-your-next-project/>`_
  - You need to copy `cloudflared`_ on your client PC.
  - You cannot specify argo tunnel server's region as it uses Argo Smart Routing technology to find the most performant path.
】
】

- `ngrok`_ 【
  【ja:アカウント(`ngrok`_ を使う場合)】
  【en:account if you use `ngrok`_】
  】

- `cloudflared`_ 【
  【ja:(`Argo Tunnel`_ を使う場合)】
  【en:if you use `Argo Tunnel`_】
  】

- 【
  【ja:Googleアカウント】
  【en:Google account】
  】

- 【
  【ja:`Google Colaboratory`_ が使えるブラウザ】
  【en:Browser that `Google Colaboratory`_ works】
  】

- 【
  【ja:sshクライアント

  Windowsを使う場合は `scoop`_ を使うと簡単にopensshをインストールできます。】

  【en:ssh client

  If you use Windows, you can install openssh with `scoop`_ .】
  】

- `TurboVNC Viewer`_

【
【ja:手順】
【en:Procedure】
】
-----

【
【ja:詳しい手順は以下のサイトをご覧下さい。】
【en:More details of this procedure:】
】

https://github.com/demotomohiro/remocolab/blob/master/README.md

【
【ja:うまくいかないときは以下のページが参考になるかもしれません。】
【en:If you have questions:】
】

https://github.com/demotomohiro/remocolab/wiki/Frequently-Asked-Questions

1. 【
   【ja:ngrokを使う場合は `ngrok`_ にサインアップ

   - 無料のプランでかまいません。】
   【en:Sign up for `ngrok`_ if you use it

   - You don't need to buy paid plans.】
   】

1. 【
   【ja:`Argo Tunnel`_ を使う場合は `cloudflared`_ をダウンロードしてインストールするか、解凍してパスが通っているディレクトリに実行ファイルをコピーする】
   【en:If you use `Argo Tunnel`_,  download `cloudflared`_ to your PC and install it or put the executable file in one of directories in PATH environment variable】
   】

2. 【
   【ja: OpenGLを使いたい場合はランタイムタイプを変更

   - `Google Colaboratory`_ を開いたら、上部メニューの"ランタイム"→"ランタイムのタイプを変更"からハードウェアアクセラレータをGPUに設定してください。】
   【en: Change runtime type if you want to use OpenGL

   - After you open `Google Colaboratory`_, click "Runtime" -> "Change runtime type" in top menu and change Hardware accelerator to GPU.】
   】

3. 【
   【ja:セルに以下のコードをコピペ
   】
   【en:Copy following code to a cell in Colaboratory】
   】

   - ngrok

     .. code::

        !pip install git+https://github.com/demotomohiro/remocolab.git
        import remocolab
        remocolab.setupVNC()

   - Argo Tunnel

     .. code::

        !pip install git+https://github.com/demotomohiro/remocolab.git
        import remocolab
        remocolab.setupVNC(tunnel = "argotunnel")

4. 【
   【ja:左上の再生ボタンのようなところをクリック】
   【en:Click run bottom in top left】
   】

   .. image:: https://user-images.githubusercontent.com/1882512/64982179-12ed6380-d8ad-11e9-8f1a-acb5d34d0ab4.png

5. 【
   【ja:ngrokを使う場合はngrokのauthtokenをコピペする

   - ngrokのauthtokenをコピペするようメッセージが表示されるのでngrokにログインして左のメニューからAuthをクリックし、Copyをクリックし、Google Colaboratoryの画面に戻ってペーストしてエンターキーを押して下さい。】
   【en:Copy ngrok authtoken if you use ngrok

   - After the message that ask you to copy ngrok authtoken displayed, login to ngrok, click Auth on left side menu, click Copy, return to Google Colaboratory, paste it and push enter key.】
   】

   .. image:: https://user-images.githubusercontent.com/1882512/64982180-12ed6380-d8ad-11e9-9db0-71854fb66d0b.png

6. 【
   【ja:ngrok regionを訊かれるので自分に一番近い場所を選んで入力

   - 今日本にいるならjpと入力してエンターキーを押します。
   】
   【en:Select ngrok region

   - Probably the region closest to you is fastest.
   】
   】
7. 【
   【ja:TurboVNCが立ち上がるまで待つ

   - OpenSSHサーバやVirtualGL, TurboVNCのセットアップなどがおこなわれます。
   - 完了するとrootとcolabユーザのパスワードとlocal port forwardingするためのsshコマンドとVNCサーバにログインするためのパスワードが表示されます。
   】
   【en:Wait for TurboVNC running

   - It setup OpenSSH server, VirtualGL and TurboVNC.
   - When it done, passwords of root and colab user, ssh command for local port forwarding and VNC password is displayed.
   】
   】
8. 【
   【ja:`Google Colaboratory`_ にSSHでログイン

   - ✂️(ハサミの絵文字)で囲まれた ``ssh`` で始まる行にあるコマンドをお手元のPCのターミナルで実行してColaboratoryのSSHサーバにログインして下さい。
   - ログイン時に必要なパスワードは"colab password: "の右に表示されています。
   - VNCを使っている間はsshでログインしたままの状態にして下さい。】
   【en:Login to `Google Colaboratory`_ using SSH

   - Login to the SSH server running on your Colaboratory's virtual machine by executing the ssh command under "Execute following command on your local machine and login before running TurboVNC viewer:" message.
   - Use the password displayed right side of "colab password: ".
   - Keep logined while you use VNC.】
   】
9. 【
   【ja:TurboVNC Viewerを実行

   - サーバのアドレスを ``localhost:1`` にして接続します。
   - パスワードが要求されるので"VNC password: "の右に表示されているパスワードをコピペしてください。】
   【en:Run TurboVNC Viewer

   - Set server address to ``localhost:1`` and connect.
   - When password is required, copy & paste the password displayed right side of "VNC password: ".】
   】

【
【ja:問題無く接続できれば以下のような画面が見えます。】
【en:After connecting VNC server, you will see the screen like this.】
】

.. figure:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_first_screen.png
   :width: 100%

【
【ja:以下のコマンドでNVIDIAのOpenGL実装が使えるかどうか確認できます。】
【en:You can check the availability of NVIDIA OpenGL implementation with following command.】
】

.. code::

  $$ vglrun /opt/VirtualGL/bin/glxinfo | grep NVIDIA

【
【ja:問題なければ以下のような出力がでるはずです。】
【en:If everything fine, you will see following output.】
】

.. code::

   OpenGL vendor string: NVIDIA Corporation
   OpenGL core profile version string: 4.6.0 NVIDIA 418.67
   OpenGL core profile shading language version string: 4.60 NVIDIA
   OpenGL version string: 4.6.0 NVIDIA 418.67
   OpenGL shading language version string: 4.60 NVIDIA

【
【ja:OpenGLを使ったプログラムを実行する】
【en:Run OpenGL programs】
】
-----

【
【ja:
以下の内容はリモートデスクトップ上で実行してください。
TurboVNC ViewerではローカルPCとリモートPC間でコピペすることができます。
OpenGLを使うプログラムを実行するときは ``vglrun`` の後に実行するプログラムを指定します。
``vglrun`` をつけずに実行するとTurboVNC付属のソフトウェアGLX/OpenGL実装が使われるのでレンダリングが遅くなります。
】
【en:
Following steps are supposed to be run on remote desktop.
TurboVNC Viewer can copy & paste between your PC and remote PC.
OpengL programs need to be run with ``vglrun`` command or it uses software GLX/OpenGL implementation included in The TurboVNC and rendering can be slow.
】
】

【
【ja:SSHからプログラムを起動しVNC上に表示したい場合には以下のように ``DISPLAY=:1`` をつけてコマンドを実行します。】
【en:If you want to run a program from SSH and display it on the VNC screen, add ``DISPLAY=:1`` to your command like this:】
】

.. code::

  $$ DISPLAY=:1 vglrun firefox &

Shadertoy
.....

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_shadertoy.png
   :width: 100%

【
【ja:ターミナルを開いて以下のコマンドでfirefoxをインストールして実行します。】
【en:Open terminal and execute following commands.】
】

.. code::

  $$ su
  # apt install firefox
  # exit
  $$ vglrun firefox

【
【ja:firefoxで `Shadertoy`_ のページを開きます。】
【en:Then, open `Shadertoy`_ on the firefox.】
】

Unigine Valley
.....

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_unigine_valley.png
   :width: 100%

【
【ja:`Unigine Valley`_ のページからUnigine Valleyをダウンロードします。
次に以下のコマンドでファイルを展開して実行します。
】
【en:Download Unigine Valley from `Unigine Valley`_ .
Then, extract the file and run it like following command.
】
】

.. code::

  $$ chmod +x Unigine_Valley-1.0.run
  $$ ./Unigine_Valley-1.0.run
  $$ cd Unigine_Valley-1.0
  $$ vglrun ./valley

Blender
.....

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_blender.png
   :width: 100%

【
【ja:`Blender`_ の公式サイトのDownloadページからLinux 64bit用のファイルをダウンロードします。
次に以下のコマンドでファイルを解凍し、実行します。
】
【en:Download the file for Linux 64bit from official `Blender`_ site.
Then, extract the file and run it like following command.
】
】

.. code::

  $$ tar xf blender-2.79b-linux-glibc219-x86_64.tar.bz2
  $$ cd blender-2.79b-linux-glibc219-x86_64
  $$ vglrun ./blender

Godot
.....

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_godot.png
   :width: 100%

【
【ja:`Godot`_ の公式サイトのDownloadページからLinux 64bit用のファイルをダウンロードします。
次に以下のコマンドでファイルを展開して実行します。
】
【en:Download the file for Linux 64bit from official `Godot`_ site.
The, extract the file and run it like following command.
】
】

.. code::

  $$ unzip Godot_v3.1-stable_x11.64.zip
  $$ vglrun ./Godot_v3.1-stable_x11.64

【
【ja:解説】
【en:How it works】
】
-----

【
【ja:`remocolab`_ はOpenSSH、 `TurboVNC`_ 、 `libjpeg-turbo`_ 、 `VirtualGL`_ 、 `Xfce`_ のダウンロードとインストールを行っています。
`TurboVNC`_ を使って `Google Colaboratory`_ の仮想マシン上にデスクトップを起動しリモートPCからアクセスできるようにしています。
`TurboVNC`_ はサーバ上のデスクトップ画面を `TurboVNC Viewer`_ を実行しているクライアントPCに送り、クライアントPCからマウスとキーボード入力を受け取ります。
`TurboVNC`_ は `libjpeg-turbo`_ を使って画面の画像を圧縮してから送信しています。
SSH port forwardingを使うことによってこれらの通信を暗号化しています。
`remocolab`_ では外部からSSHを使わず直接TurboVNCに接続することができないように設定しています。
OpenGLを使うプログラムを実行するときにVirtualGLを使うことによってTurboVNC上でも普通のデスクトップ上で実行したときと同じようにサーバ上のGPUを使ったハードウェアアクセラレーションが効くようにしています。
】
【en:`remocolab`_ download and install OpenSSH, `TurboVNC`_ , `libjpeg-turbo`_, `VirtualGL`_ and `Xfce`_ .
It run desktop on `Google Colaboratory`_ 's virtual machine and make it accessible from your PC using `TurboVNC`_.
`TurboVNC`_ send desktop screen on the server to the client PC running `TurboVNC Viewer`_ , and receive mouse and keyboard input from the client PC.
`TurboVNC`_  compress desktop screen image using `libjpeg-turbo`_ before sending it.
These communications are encrypted by using SSH port forwarding.
`remocolab`_ configures TurboVNC so that connecting to it without using SSH is forbidden.
VirtualGL allow OpenGL programs can use Hardware accelerator using a GPU on server like they are executed on normal desktop.
】
】

【
【ja:動きを滑らかにする方法】
【en:Display smooth animation】
】
-----

【
【ja:TurboVNC Viewer Optionsを開き、Encoding methodを ``Tight + Medium-Quality JPEG`` または ``Tight + Low-Quality JPEG(WAN)`` に設定します。
ノイズが見えるようになりますが、カクツキが軽減します。
】
【en:Open TurboVNC Viewer Options and change Encoding method to ``Tight + Medium-Quality JPEG`` or ``Tight + Low-Quality JPEG(WAN)`` .
Some noise will appear but looks smoother.
】
】

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_turbovnc_option.png

.. image:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_turbovnc_enc.png

【
【ja:画面サイズを変更する方法】
【en:Change remote desktop size】
】
-----
【
【ja:TurboVNC Viewer Optionsを開き、 *Connection* タブをクリックして *Remote desktop size* に好きなサイズを設定します。】
【en:Open TurboVNC Viewer Options, click *Connection* tab and set *Remote desktop size*.】
】

.. image:: https://gist.githubusercontent.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/6bf176dbfa900158b910f3548ccb3672085cf53d/googlecolab_vnc_turbovnc_desktopsize.png

`Frequently-Asked-Questions <https://github.com/demotomohiro/remocolab/wiki/Frequently-Asked-Questions>`_

.. _Google Colaboratory: https://colab.research.google.com/
.. _ngrok: https://ngrok.com/
.. _Argo Tunnel: https://www.cloudflare.com/products/argo-tunnel/
.. _cloudflared: https://developers.cloudflare.com/argo-tunnel/downloads
.. _Scoop: https://scoop.sh/
.. _TurboVNC Viewer: https://sourceforge.net/projects/turbovnc/files
.. _remocolab: https://github.com/demotomohiro/remocolab
.. _Shadertoy: https://www.shadertoy.com/
.. _Unigine Valley: https://benchmark.unigine.com/valley
.. _Blender: https://www.blender.org/
.. _Godot: https://godotengine.org/
.. _TurboVNC: https://www.turbovnc.org/
.. _libjpeg-turbo: https://www.libjpeg-turbo.org/
.. _VirtualGL: https://www.virtualgl.org/
.. _Xfce: https://xfce.org/
"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"【素でタダ】Google ColaboratoryでOpenGLを使ったデスクトッププログラムを動かす",
    description:"Google Colaboratory上にVNCサーバを稼働させてOpenGLを使ったデスクトッププログラムを利用する方法を紹介します",
    category:"Google Colaboratory")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"How to run OpenGL desktop programs on Google Colaboratory",
    description:"Explains how to run a VNC server and OpenGL desktop program on Google Colaboratory",
    category:"Google Colaboratory"))])
newArticle(articles, rstText)
