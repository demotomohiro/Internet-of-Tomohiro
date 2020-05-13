const rstText = """
【
【ja:】
【en:】
】
【
【ja:Google Colaboratoryで見つけたセキュリティ問題について】
【en:Security problem found in Google Colaboratory】
】
======

【
【ja:
一か月前頃に `Google Colaboratory`_ で `OpenSSH`_ serverに関係するセキュリティ問題を見つけてGoogleに報告しました。
おかげでBughunterのHonorable Mentionsに載りました！
】
【en:
I have found a security problem in `Google Colaboratory`_ that related to `OpenSSH`_ server and I reported it to Google.
I got listed on the Honorable Mentions in the Bughunter.
】
】
https://bughunter.withgoogle.com/profile/d9c76300-d251-4f1d-988a-49abcc06b809

【
【ja:
今はその問題は修正されています。
この問題は `Google Colaboratory`_ で割り当てられる仮想マシン上で `OpenSSH`_ serverを立ち上げてインターネットからログインできるようにした場合に関係してきます。
`Google Colaboratory`_ のユーザの殆どはそのようなことはしないと思うのですが、 `以前にその方法を記事に書きましたし、 <ssh.ja.html>`_
インターネット上でそのような話題が見かけられれます。
このようなSSHからGoogle Colaboratoryにログインするためのコードも公開されています。
】
【en:
This problem has been fixed.
This bug was a problem in the case you run `OpenSSH`_ server on a Google Colaboratory's virtual machine and allow you to login to the machine through the internet. 
I think most of Google Colaboratory users don't do that, but `I wrote a article about how to do that <ssh.en.html>`_ and there are people talking about it on the internet.
I found a following code to run OpenSSH server on the Google Colaboratory and allow you to login to it.
】
】
https://gist.github.com/creotiv/d091515703672ec0bf1a6271336806f0

----

【
【ja:
ところで、このコードではPythonのrandomモジュールからパスワードを生成していますがそのモジュールはセキュリティや暗号学的に設計されてはいません。secretsモジュールを使ってパスワードを生成すべきです。詳しくは以下のリンクを参照してください。
https://docs.python.org/ja/3/library/secrets.html
】
【en:
By the way, this code generates a password using Python's random module. But it is not designed for security or cryptography.
It should generate a password using secrets module. Please check following link for more details.
https://docs.python.org/3/library/secrets.html
】
】

----


【
【ja:
問題を見つけたときにはGoogle Colaboratoryの仮想マシンにOpenSSH serverがデフォルトでインストールされていました。
下記のファイルはSSHサーバが認証に使用するprivate host keyで、サーバ毎にユニークで秘密になっている必要があります。
】
【en:
When I found the problem, OpenSSH server was installed in all Google Colaboratory's virtual machines.
Following files are private host keys used for authenticating computers and they should be unique and secret.
】
】

.. code::

  /etc/ssh/ssh_host_ecdsa_key
  /etc/ssh/ssh_host_ed25519_key
  /etc/ssh/ssh_host_rsa_key

【
【ja:Colaboratoryでコードセルを追加して以下のコードを実行すると中身を見ることができました。】
【en:You can see the content of these files by running following code in a cell of Colaboratory.】
】

.. code::

  !cat /etc/ssh/ssh_host_ecdsa_key
  !cat /etc/ssh/ssh_host_ed25519_key
  !cat /etc/ssh/ssh_host_rsa_key

【
【ja:
問題だったのはこれらのprivate host keyが常に同じ内容だった事です。
ランタイムをリセット、ランタイムタイプを変更、別のアカウントでログインするなどしてもファイルの中身が変わることがありませんでした。
つまりColaboratoryで使われるすべての仮想マシンでこれらのファイルが同じ内容だったのです。
秘密にすべきファイルが秘密になっていないということです。
以下のサイトでこのキーが攻撃者に知られると中間者攻撃が可能になることが説明されています。
】
【en:
The problem is these private host keys were never changed. I reset a runtime, changed runtime type or login as another user,  but the content of these files never changed.
That means files need to be secret were actually public.
Following site explains that if a attacker got a private host key, he can perform man-in-the-middle attacks.
】
】

- https://www.ssh.com/ssh/host-key
- https://www.ssh.com/attack/man-in-the-middle

【
【ja:
今はopenssh-serverパッケージがインストールされなくなったので問題は解決しました。
private host keyはopenssh-serverインストール時に生成されるので、各ユーザが個別にインストールすればランダムでユニークな値になるはずです。
そもそも何故openssh-serverがデフォルトでインストールされていたかは謎です。
】
【en:
That problem has been fixed by not installing openssh-server package.
Private host keys are generated when openssh-server is installed and these files should have random and unique value.
I still don't know why openssh-server was installed on Colaboratory's virtual machines.
】
】

【
【ja:
マシンに必要なプログラムをインストールした後にシステム全体を一つのimageファイルとして保存し、後で同じシステムを持ったマシンを簡単に作れるようにすることがあると思います。
SSHサーバインストール時にprivate host keyが生成され、そのファイルを消さずにimageファイルを作り、さらにそのimageファイルを公開したら同様の問題が起こることになります。
imageファイルを秘密にしておくか、imageファイルを作る前にprivate host keyを消しましょう。
】
【en:
Some people install all programs they want to use and copy whole file system as a image file so that they can easily make a machine with same file system.
As private host keys are generated when installing OpenSSH server, if you create a image file after installing OpenSSH server without removing private host keys and publish the image, you would get the similar problem.
You have to keep the image file secret or remove private host keys before creating a image file.
】
】

.. _Google Colaboratory: https://colab.research.google.com/
.. _OpenSSH: https://www.openssh.com/

"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"Google Colaboratoryで見つけたセキュリティ問題について",
    description:"Google ColaboratoryでOpenSSH serverを使うときに関係するセキュリティ問題を見つけたので説明します",
    category:"Google Colaboratory")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"Security problem found in Google Colaboratory",
    description:"Explain about security problem found in Google Colaboratory that related to OpenSSH server",
    category:"Google Colaboratory"))])
newArticle(articles, rstText)

