const rstText = """
# 【
【ja:このブログについて】
【en:About this blog】
】

【
【ja:このブログは `Nim De Blog`_ を使って作成され、 `Netlify`_ からホスティングされています。
このブログのソースコードはGithubの `このリポジトリ <https://github.com/demotomohiro/Internet-of-Tomohiro>`_ で管理されています。
`Nim De Blog`_ は `Nim`_ プログラミング言語で書かれた静的サイトプログラムで、Nim言語とNimの標準ライブラリで実装されているreStructuredTextを使って簡単にブログを書くことができます。
】
【en:This blog is created with `Nim De Blog`_ and hosted by `Netlify`_.
Source code of this blog is in `this repository <https://github.com/demotomohiro/Internet-of-Tomohiro>`_.
`Nim De Blog`_ is a static site generater written with `Nim`_ programming language.
I can write articles using Nim language and reStructuredText implemented in Nim standard library.
】
】

## 【
【ja:Netlifyの仕組み】
【en:How Netlify works】
】

【
【ja:`Netlify`_ は静的サイトを生成しインターネット上に公開します。】
【en:`Netlify`_ generate static site and deploy it.】
】
【
【ja:
1. Github, GitLab, Bitbucketのどれかに静的サイト生成に必要なファイルを含んだリポジトリを作る
2. NetlifyにSign upする
3. "New site from Git"をクリックし1で作ったリポジトリを指定してサイトを作る
4. Netlifyのサーバーが自動的にリポジトリをgit cloneし、登録したコマンドの実行が行われる
5. 登録したコマンドが静的サイトの生成に成功するとインターネット上に公開される

以後、リポジトリにpushされるたびにNetlifyが4, 5を行う。
】
【en:
1. Create a repository that has files used to generate static site at Github, GitLab or Bitbucket.
2. Sign up Netlify
3. Click "New site from Git" and specify the repository
4. Netlify server automatically do git clone the repository and execute the command you registered
5. if that command succeeded, generated static site become accessible from internet.

After that, Netlify do 4 and 5 everytime you do git push to the repository.
】
】

## 【
【ja:NetlifyでNimを使う】
【en:Use Nim in Netlify】
】

【
【ja:NetlifyでNimを使うにはNetlify上でNimをビルドする必要があります。
そのためのスクリプトを作成し、 `netlify-nim-test`_ で公開しています。
】
【en:Nim needs to be built on Netlify in order to use it.
I wrote scripts to do that and published on `netlify-nim-test`_.
】
】

## 【
【ja:このブログのコメント機能について】
【en:Comment widget in this blog】
】

【
【ja:静的サイトそのものではコメント機能を作ることはできません。
そこでこのブログでは `utterances`_ を使ってコメントを書き込めるようにしました。
`utterances`_ ではコメントがGithub issuesに記録されます。
コメントを書き込むにはGithubアカウントが必要になりますが、Github issuesでコメントを管理したりMarkdownでコメントを書くことができます。
】
【en:It is impossible to make a comments system only with static site.
So this blog use `utterances`_ comments widget.
It is built on GitHub issues and you can manage comments on Github issues and post comments using Markdown but posting comments requires Github account.
】
】

.. _Netlify: https://www.netlify.com/
.. _Nim: https://nim-lang.org/
.. _Nim De Blog: https://github.com/demotomohiro/nim-de-blog
.. _netlify-nim-test: https://github.com/demotomohiro/netlify-nim-test
.. _utterances: https://utteranc.es/
"""

let articles = newTable([
  (Lang("ja"),
  ArticleSrcLocal(
    title:"このブログについて",
    description:"このブログはNetlifyとNim言語で作られています")),
  (Lang("en"),
  ArticleSrcLocal(
    title:"About this blog",
    description:"This blog is created with Netlify and Nim language"))])
newArticle(articles, rstText)
