import nimDeBlog

proc main =
  let indexLink = """
`【
【ja:記事一覧へ】
【en:index】
】 <$indexPageLink>`_
"""
  let articleHead = indexLink & """
$otherLangLinks

Internet of Tomohiro

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
  let rstSrcHead = """
Internet of Tomohiro
======

| Twitter: @demotomohiro
| Github: https://github.com/demotomohiro
| pouët.net: http://www.pouet.net/user.php?who=54687

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
          postIndex       = rstSrcFoot)
when isMainModule:
  main()
