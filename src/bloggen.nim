import nimDeBlog
import strformat

proc main =
  let indexLink = """
`【
【ja:記事一覧へ】
【en:index】
】 <$indexPageLink>`_
"""
  let donate = """
.. raw:: html

  <a href="https://blockchain.info/address/【
  【ja:1FoBiuf8E35BYdoEesV2v3BkcZBnZ7YfA6】
  【en:1A9Ar3vLYH4f2U7dKYuNgsaqXYUCpZmiGP】
  】">
    <img src="https://img.shields.io/badge/bitcoin-【
  【ja:1FoBiuf8E35BYdoEesV2v3BkcZBnZ7YfA6】
  【en:1A9Ar3vLYH4f2U7dKYuNgsaqXYUCpZmiGP】
  】-brightgreen.svg"/></a>

  <a href="https://www.paypal.me/demotomohiro"><img src="https://img.shields.io/badge/ -paypal.me-blue.svg"/></a>
"""

  let articleHead = indexLink & fmt"""
$otherLangLinks

Internet of Tomohiro

{donate}

----
"""
  let articleFoot = """
----

【
【ja:by Tomohiro】
【en:by Tomohiro】
】

""" & indexLink & """

.. raw:: html

   <script src="https://utteranc.es/client.js"
     repo="demotomohiro/Internet-of-Tomohiro"
     issue-term="pathname"
     theme="github-light"
     crossorigin="anonymous"
     async>
   </script>
"""
  let rstSrcHead = fmt"""
Internet of Tomohiro
======

| Twitter: @demotomohiro
| Github: https://github.com/demotomohiro
| pouët.net: http://www.pouet.net/user.php?who=54687

{donate}

【
【ja:記事一覧】
【en:Article list】
】
------
"""

  let rstSrcFoot = ""

  makeBlog(
          articlesSrcDir  = "articles",
          articlesDstDir  = "../public",
          execDstDir      = "bin",
          header          = articleHead,
          footer          = articleFoot,
          title           = "Internet of Tomohiro",
          description     = """【
                               【ja:Tomohiroのブログです】
                               【en:Blog site created by Tomohiro】
                               】""",
          preIndex        = rstSrcHead,
          postIndex       = rstSrcFoot,
          cssPath         = "../public/style.css")
when isMainModule:
  main()
