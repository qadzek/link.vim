" Convert ---------------------------------------------------------- {{{1

command -buffer -bar        MdLinkConvertSingle
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :call mdlink#Convert('single-link')

command -buffer -bar        MdLinkConvertSingleInsert
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :call mdlink#Convert('single-link', 'insert')

command -buffer -bar -range MdLinkConvertRange
      \ let b:init_cur_pos = getcurpos()[1:2] |
      \ :<line1>,<line2>call mdlink#Convert()

command -buffer -bar        MdLinkConvertAll            :% MdLinkConvertRange

" Jump etc. -------------------------------------------------------- {{{1

command -buffer -bar        MdLinkOpen                  :call mdlink#Open()
command -buffer -bar        MdLinkPeek                  :call mdlink#Peek()
command -buffer -bar        MdLinkJump                  :call mdlink#Jump()

" Delete ----------------------------------------------------------- {{{1

command -buffer -bar        MdLinkDelete                :call mdlink#Delete()

" vim:fdm=marker
