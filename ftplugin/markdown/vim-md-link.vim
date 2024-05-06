" Convert ---------------------------------------------------------- {{{1

" Store cursor position before range function moves it
command -buffer -bar -range MdLinkConvertRange
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :<line1>,<line2>call mdlink#Convert()

command -buffer -bar        MdLinkConvertAll            :% MdLinkConvertRange

command -buffer -bar        MdLinkConvertSingle
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :call mdlink#Convert('single-link')

command -buffer -bar        MdLinkConvertSingleInsert
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :call mdlink#Convert('single-link', 'insert')

" Jump etc. -------------------------------------------------------- {{{1

command -buffer -bar        MdLinkJump                  :call mdlink#Jump('jump')
command -buffer -bar        MdLinkOpen                  :call mdlink#Jump('open')
command -buffer -bar        MdLinkPeek                  :call mdlink#Jump('peek')

  " Reformat ------------------------------------------------------- {{{1

command -buffer -bar        MdLinkReformat              :call mdlink#Reformat()

" vim:fdm=marker
