" =============================================================================
" Filename: autoload/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/05/24 15:09:10.
" =============================================================================

let s:utf = &enc ==# 'utf-8'

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:e = {
      \ 'ControlP' : "get(g:lightline, 'ctrlp_item', expand('%:t'))",
      \ '__Tagbar__' : "get(g:lightline, 'fname', expand('%:t'))",
      \ '__Gundo__' : "''",
      \ '__Gundo_Preview__' : "''",
      \ 'vimfiler' : 'vimfiler#get_status_string()',
      \ 'unite' : 'unite#get_status_string()',
      \ 'vimshell' : "exists('b:vimshell.current_dir') ? substitute(b:vimshell.current_dir,expand('~'),'~','') : default",
      \ 'quickrun' : "''",
      \ 'qf' : "''",
      \ 'vimcalc' : "''",
      \ 'dictionary' : "exists('b:dictionary.input') ? b:dictionary.input : default",
      \ 'calendar' : "strftime('%Y/%m/%d')",
      \ 'thumbnail' : "exists('b:thumbnail.status') ? b:thumbnail.status : 'Thumbnail'",
      \ 'agit' : "''",
      \ 'agit_diff' : "''",
      \ 'agit_stat' : "''",
      \ 'github-dashboard': "''",
      \ '[Command Line]': "''",
      \ }
let s:f = [ 'ControlP', '__Tagbar__', 'vimfiler', 'unite', 'vimshell', 'dictionary', 'thumbnail' ]
let s:ro = s:utf ? "\u2b64" : 'RO'
function! lightline_powerful#filename() abort
  let f = expand('%:t')
  if has_key(b:, 'lightline_filename') && get(b:, 'lightline_filename_', '') ==# f . &mod . &ma && index(s:f, &ft) < 0 && index(s:f, f) < 0
    return b:lightline_filename
  endif
  let b:lightline_filename_ = f . &mod . &ma
  let default = join(filter([&ro ? s:ro : '', f, &mod ? '+' : &ma ? '' : '-'], 'len(v:val)'), ' ')
  let b:lightline_filename = f =~# '^NERD_tree' ? '' : f =~# '^\[preview' ? 'Preview' : eval(get(s:e, &ft, get(s:e, f, 'default')))
  if len(b:lightline_filename) > winwidth(0)
    let b:lightline_filename = matchstr(b:lightline_filename, repeat('.', strchars(b:lightline_filename) * winwidth(0) / len(b:lightline_filename)))
  endif
  return b:lightline_filename
endfunction

let s:fu = s:utf ? "\u2b60 " : ''
function! lightline_powerful#fugitive() abort
  if has_key(b:, 'lightline_fugitive') && reltimestr(reltime(b:lightline_fugitive_)) =~# '^\s*0\.[0-3]'
    return b:lightline_fugitive
  endif
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD\|^$' && &ft !~? 'vimfiler'
      if exists('*gitbranch#name')
        let _ = gitbranch#name()
      elseif exists('*fugitive#head')
        let _ = fugitive#head()
      else
        return ''
      endif
      let b:lightline_fugitive = strlen(_) ? s:fu._ : ''
      let b:lightline_fugitive_ = reltime()
      return b:lightline_fugitive
    endif
  catch
  endtry
  return ''
endfunction

function! lightline_powerful#fileformat() abort
  return &ft !=# 'vimfiler' && winwidth(0) > 70 ? &ff : ''
endfunction

function! lightline_powerful#filetype() abort
  return &ft !=# 'vimfiler' && winwidth(0) > 70 ? (strlen(&ft) ? &ft : 'no ft') : ''
endfunction

function! lightline_powerful#fileencoding() abort
  return &ft !=# 'vimfiler' && winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! lightline_powerful#ctrlpmark() abort
  if expand('%:t') !=# 'ControlP'
    if &ft ==# 'calendar' && has_key(b:, 'calendar') && has_key(b:calendar, 'visual_mode')
      call lightline#link("nvV\<C-v>"[b:calendar.visual_mode()])
    endif
    if &ft ==# 'thumbnail' && has_key(b:, 'thumbnail') && has_key(b:thumbnail, 'visual_mode')
      if b:thumbnail.visual_mode < 4
        call lightline#link("nvV\<C-v>i"[get(b:thumbnail,'insert_mode') ? 4 : b:thumbnail.visual_mode])
      endif
    endif
    return ''
  else
    call lightline#link('iR'[get(g:lightline, 'ctrlp_regex', 0)])
    if has_key(g:lightline, 'ctrlp_prev') && has_key(g:lightline, 'ctrlp_item') && has_key(g:lightline, 'ctrlp_next')
      return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item, g:lightline.ctrlp_next], 0)
    else
      return ''
    endif
  endif
endfunction

let s:m = { 'ControlP': 'CtrlP', '__Tagbar__': 'Tagbar', '__Gundo__': 'Gundo', '__Gundo_Preview__': 'Gundo Preview', '[Command Line]': 'Command Line'}
let s:p = { 'unite': 'Unite', 'vimfiler': 'VimFiler', 'vimshell': 'VimShell', 'quickrun': 'Quickrun', 'dictionary': 'Dictionary', 'calendar': 'Calendar', 'thumbnail': 'Thumbnail', 'vimcalc': 'VimCalc', 'agit' : 'Agit', 'agit_diff' : 'Agit', 'agit_stat' : 'Agit', 'qf': 'QuickFix', 'github-dashboard': 'GitHub Dashboard' }
function! lightline_powerful#mode() abort
  return get(s:m, expand('%:t'), get(s:p, &ft, winwidth(0) > 60 ? lightline#mode() : ''))
endfunction

let g:tagbar_status_func = 'lightline_powerful#TagbarStatusFunc'
function! lightline_powerful#TagbarStatusFunc(current, sort, fname, ...) abort
  let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

let g:ctrlp_status_func = { 'main': 'lightline_powerful#CtrlPStatusFunc_1', 'prog': 'lightline_powerful#CtrlPStatusFunc_2' }
function! lightline_powerful#CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked) abort
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! lightline_powerful#CtrlPStatusFunc_2(str) abort
  return lightline#statusline(0)
endfunction

function! lightline_powerful#tabreadonly(n) abort
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&readonly') ? s:ro : ''
endfunction

function! lightline_powerful#tabfilename(n) abort
  let bufnr = tabpagebuflist(a:n)[tabpagewinnr(a:n) - 1]
  let bufname = expand('#' . bufnr . ':t')
  let buffullname = expand('#' . bufnr . ':p')
  let bufnrs = filter(range(1, bufnr('$')), 'v:val != bufnr && len(bufname(v:val)) && bufexists(v:val) && buflisted(v:val)')
  let i = index(map(copy(bufnrs), 'expand("#" . v:val . ":t")'), bufname)
  let ft = gettabwinvar(a:n, tabpagewinnr(a:n), '&ft')
  if strlen(bufname) && i >= 0 && map(bufnrs, 'expand("#" . v:val . ":p")')[i] != buffullname
    let fname = substitute(buffullname, '.*/\([^/]\+/\)', '\1', '')
  else
    let fname = bufname
  endif
  return fname =~# '^\[preview' ? 'Preview' : get(s:m, fname, get(s:p, ft, fname))
endfunction

function! lightline_powerful#syntasticerror() abort
  if exists('b:syntastic_loclist') && has_key(b:syntastic_loclist, 'errors') && len(b:syntastic_loclist.errors())
    return substitute(substitute(substitute(b:syntastic_loclist.errors()[0].text, '%', '%%', 'g'), '\[Char\]', 'String', 'g'), '\%(note: \|\(.*unable to load package\|In the second argument of\|Declared at: \| or explicitly provide\).*\|‘\|’\|Perhaps you .*\| (imported from[^)]*)\|(visible) \|It could refer to either.*\|It is a member of the .*\|In the expression:.*\|Probable cause:.*\|GHC\.\%(Types\|Base\|[a-zA-Z]\+\.Type\)\.\|In the [a-z]\+ argument of.*\|integer-gmp:\)', '', 'g')
  endif
  return ''
endfunction

function! lightline_powerful#syntasticwarning() abort
  if exists('b:syntastic_loclist') && has_key(b:syntastic_loclist, 'warnings') && has_key(b:syntastic_loclist, 'errors')
        \ && len(b:syntastic_loclist.warnings()) && !len(b:syntastic_loclist.errors())
    return substitute(substitute(substitute(substitute(b:syntastic_loclist.warnings()[0].text, '%', '%%', 'g'), '\[Char\]', 'String', 'g'), '\.hs:\d\+:\d\+-\d\+\zs.*', '', ''), '\(\(Defaulting the following constraint\|: Patterns not matched\| except perhaps to import instances from \).*\|forall [a-z]\. \|GHC\.\%(Types\|Base\)\.\|integer-gmp:\)', '', 'g')
  endif
  return ''
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
