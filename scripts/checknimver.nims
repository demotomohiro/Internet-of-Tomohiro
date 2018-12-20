import strscans

proc main() =
  let reqVer = paramStr(paramCount())

  var reqMajor, reqMinor, reqPatch: int
  if scanf(reqVer, "$i.$i.$i", reqMajor, reqMinor, reqPatch):
    if (
        (NimMajor > reqMajor) or
        (NimMajor == reqMajor and NimMinor > reqMinor) or
        (NimMajor == reqMajor and NimMinor == reqMinor and NimPatch >= reqPatch)):
      quit QuitSuccess

  quit QuitFailure

main()
