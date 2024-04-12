command -buffer -bar        MdLinkConvertSingle
      \ :call mdlink#ConvertSingleLink()

command -buffer -bar        MdLinkConvertSingleInsert
      \ :call mdlink#ConvertSingleLink('insert')

command -buffer -bar -range MdLinkConvertRange
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :<line1>,<line2>call mdlink#ConvertRange()

command -buffer -bar        MdLinkConvertAll            :% MdLinkConvertRange

command -buffer -bar        MdLinkOpen                  :call mdlink#Open()
command -buffer -bar        MdLinkPeek                  :call mdlink#Peek()
command -buffer -bar        MdLinkJump                  :call mdlink#Jump()

command -buffer -bar        MdLinkDeleteUnneededRefs
      \ :call mdlink#DeleteUnneededRefs()

command -buffer -bar -range MdLinkPreProcessUrls
      \ :<line1>,<line2>call mdlink#ProcessUrls('pre')

command -buffer -bar -range MdLinkPostProcessUrls
      \ :<line1>,<line2>call mdlink#ProcessUrls('post')

command -buffer -bar -range MdLinkProcessConvert
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :<line1>,<line2>call mdlink#ProcessConvert()

command -buffer -bar        MdLinkPreProcessUrlsAll     :% MdLinkPreProcessUrls
command -buffer -bar        MdLinkPostProcessUrlsAll    :% MdLinkPostProcessUrls
command -buffer -bar        MdLinkProcessConvertAll     :% MdLinkProcessConvert
