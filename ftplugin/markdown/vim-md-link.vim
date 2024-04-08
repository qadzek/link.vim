command -buffer        MdLinkConvertSingle                      :call mdlink#ConvertSingleLink()
command -buffer        MdLinkConvertSingleInsert                :call mdlink#ConvertSingleLink('insert')
command -buffer -range MdLinkConvertRange        :<line1>,<line2>call mdlink#ConvertRange()
command -buffer        MdLinkConvertAll                         :% MdLinkConvertRange
command -buffer        MdLinkOpen                               :call mdlink#Open()
command -buffer        MdLinkPeek                               :call mdlink#Peek()
command -buffer        MdLinkJump                               :call mdlink#Jump()
command -buffer        MdLinkDeleteUnneededRefs                 :call mdlink#DeleteUnneededRefs()
