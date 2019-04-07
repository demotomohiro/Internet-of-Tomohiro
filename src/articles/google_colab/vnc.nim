const rstText = """
【
【ja:【【素でタダ】】Google ColaboratoryでOpenGLを使ったデスクトッププログラムを動かす【【STADIAモドキ】】】
【en:How to run OpenGL desktop programs on Google Colaboratory】
】
======

.. figure:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_unigine_valley_cap.png

   【
   【ja:Unigine ValleyをGoogle Colaboratoryで動かしているところ】
   【en:Unigine Valley Running on Google Colaboratory】
   】

【
【ja:必要なもの】
【en:Requirements】
】
-----

- 【
  【ja:Googleアカウント】
  【en:Google account】
  】

- 【
  【ja:`ngrok`_ アカウント】
  【en:`ngrok`_ account】
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

1. 【
   【ja:`Google Colaboratory`_ にSSHでログイン

   - `こちらの記事 <ssh.ja.html>`_ を参考にして `Google Colaboratory`_ にsshでログインします。
     このときにあらかじめ上部メニューの"ランタイム"→"ランタイムのタイプを変更"からハードウェアアクセラレータをGPUに設定してください。
     sshクライアントを実行するときに使うコマンドは"If you use VNC:"の下にあるコマンドを使用して下さい。
     sshでログインしたままの状態で以下の手順を実行して下さい。】
   【en:Login to `Google Colaboratory`_ using SSH

   - Please read `this post <ssh.en.html>`_ and login to `Google Colaboratory`_ using ssh.
     Before executing that script, you need to click "Runtime" -> "Change runtime type" in top menu and change Hardware accelerator to GPU.
     When you run ssh client, use command under "If you use VNC:".
     Execute following steps with keep logined.  】
   】
2. 【
   【ja:TurboVNC_VirtualGL.ipynbをGoogleドライブへコピーする

   - `Google Colaboratory SSH samples`_ の ``src`` ディレクトリから ``TurboVNC_VirtualGL.ipynb`` をダウンロードして自分のGoogleドライブへコピーし、Colaboratoryで開きます。】
   【en:Copy TurboVNC_VirtualGL.ipynb to your Google drive

   - Download ``TurboVNC_VirtualGL.ipynb`` from ``src`` directory of `Google Colaboratory SSH samples`_, copy it to your Google drive and open it with Colaboratory.】
   】
3. 【
   【ja:ハードウェアアクセラレータをGPUに設定

   - 上部メニューの"ランタイム"→"ランタイムのタイプを変更"からハードウェアアクセラレータをGPUに設定してください。】
   【en:set Hardware accelerator to GPU

   - In top menu, "Runtime" -> "Change runtime type" and set Hardware accelerator to GPU.】
   】
4. 【
   【ja:左上の再生ボタンのようなところをクリック

   - 実行してしばらくすると下のほうにVNC passwordが表示されます。】
   【en:Click run button in top left

   - After few seconds, VNC password will be displayed.】
   】
5. 【
   【ja:TurboVNC Viewerを実行

   - サーバのアドレスを ``localhost:1`` にして接続します。
     パスワードが要求されるので4で表示されたVNC passwordを入力してください。】
   【en:Run TurboVNC Viewer

   - Set server address to ``localhost:1`` and connect.
     When password is required, input VNC password that is displayed in step 4.】
   】

【
【ja:問題無く接続できれば以下のような画面が見えます。】
【en:After connecting VNC server, you will see the screen like this.】
】

.. figure:: https://gist.github.com/demotomohiro/53d631aaf5b9680ddaefa55a98b1ac60/raw/99fbf1cb0aea4896fcb9cadf2e9758bfb7b7561b/googlecolab_vnc_first_screen.png
   :scale: 100 %

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
  OpenGL core profile version string: 4.6.0 NVIDIA 410.79
  OpenGL core profile shading language version string: 4.60 NVIDIA
  OpenGL version string: 4.6.0 NVIDIA 410.79
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
【ja:``TurboVNC_VirtualGL.ipynb`` では `TurboVNC`_ 、 `libjpeg-turbo`_ 、 `VirtualGL`_ 、 `Xfce`_ のダウンロードとインストールを行っています。
`TurboVNC`_ を使って `Google Colaboratory`_ のサーバ上にデスクトップを起動しリモートPCからアクセスできるようにしています。
`TurboVNC`_ はサーバ上のデスクトップ画面を `TurboVNC Viewer`_ を実行しているクライアントPCに送り、クライアントPCからマウスとキーボード入力を受け取ります。
`TurboVNC`_ は `libjpeg-turbo`_ を使って画面の画像を圧縮してから送信しています。
SSH port forwardingを使うことによってこれらの通信を暗号化しています。
``TurboVNC_VirtualGL.ipynb`` では外部からSSHを使わず直接TurboVNCに接続することができないように設定しています。
OpenGLを使うプログラムを実行するときにVirtualGLを使うことによってTurboVNC上でも普通のデスクトップ上で実行したときと同じようにハードウェアアクセラレーションが効きくようにしています。
】
【en:``TurboVNC_VirtualGL.ipynb`` install and download `TurboVNC`_ , `libjpeg-turbo`_, `VirtualGL`_ and `Xfce`_ .
It run desktop on `Google Colaboratory`_ server and make it accessible to your PC using `TurboVNC`_ .
`TurboVNC`_ send desktop screen on the server to the client PC running `TurboVNC Viewer`_ , and receive mouse and keyboard input from the client PC.
`TurboVNC`_  compress desktop screen image using `libjpeg-turbo`_ before sending it.
These communications are encrypted by using SSH port forwarding.
``TurboVNC_VirtualGL.ipynb`` configures TurboVNC so that connecting to it without using SSH is forbidden.
VirtualGL allow OpenGL programs can use Hardware accelerator like they are executed on normal desktop.
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

.. _Google Colaboratory: https://colab.research.google.com/
.. _ngrok: https://ngrok.com/ 
.. _Scoop: https://scoop.sh/
.. _TurboVNC Viewer: https://sourceforge.net/projects/turbovnc/files
.. _Google Colaboratory SSH samples: https://github.com/demotomohiro/Google-Colaboratory-SSH-samples
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
    description:"Google Colaboratory上にVNCサーバを稼働させてOpenGLを使ったデスクトッププログラムを利用する方法を紹介します")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"How to run OpenGL desktop programs on Google Colaboratory",
    description:"Explains how to VNC server on Google Colaboratory and use OpenGL desktop program on it"))])
newArticle(articles, rstText)
