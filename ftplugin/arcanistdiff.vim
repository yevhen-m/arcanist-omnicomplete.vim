" Vim global plugin for correcting typing mistakes
" License:	This file is placed in the public domain.

if exists("g:loaded_arcanist_omnicomplete")
  finish
endif
let g:arcanist_omnicomplete = 1

function! s:EchoError(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

if !has('python')
  call s:EchoError("arcanist-omnicomplete error: Required vim compiled with +python")
  finish
endif

if !exists('g:conduit_api_url')
  call s:EchoError("arcanist-omnicomplete error: g:conduit_api_url not defined")
  finish
endif

if !exists('g:conduit_api_token')
  call s:EchoError("arcanist-omnicomplete error: g:conduit_api_token not defined")
  finish
endif

python << EOF
import sys
import vim

# Turn off creating *.pyc files
sys.dont_write_bytecode = True
# Add script's dir to the python path and import it into the global namespace.
sys.path.append(vim.eval('expand("<sfile>:h")'))
import arcanistdiff
EOF

function! s:GetReviewersFromConduit(api_url, api_token)
  let reviewers = pyeval(
        \ 'arcanistdiff.ConduitClient("'
        \ . a:api_url .
        \ '", "'
        \ . a:api_token .
        \ '").fetch_users()'
        \ )

  function! s:GetUsernameCandidate(reviewer)
    return {
          \ 'word': a:reviewer.userName,
          \ 'abbr': a:reviewer.userName,
          \ 'menu': '(username)',
          \ }
  endfunction

  function! s:GetRealNameCandidate(reviewer)
    return {
          \ 'word': a:reviewer.userName,
          \ 'abbr': a:reviewer.realName,
          \ 'menu': '(real name)',
          \ }
  endfunction

  let res = []
  for reviewer in reviewers
    call add(res, s:GetUsernameCandidate(reviewer))
    call add(res, s:GetRealNameCandidate(reviewer))
  endfor
  return res
endfunction

let s:cached_reviewers = []

function! CompleteReviewers(findstart, base)
  " omnicomplete for active phabricator users
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    if empty(s:cached_reviewers)
      let s:cached_reviewers = s:GetReviewersFromConduit(
            \ g:conduit_api_url,
            \ g:conduit_api_token
            \ )
    endif
    let res = []
    for reviewer in s:cached_reviewers
      if reviewer.abbr =~? a:base
        call add(res, reviewer)
      endif
    endfor
    return res
  endif
endfunction

setlocal omnifunc=CompleteReviewers
