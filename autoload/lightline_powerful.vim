" =============================================================================
" Filename: autoload/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/24 11:07:42.
" =============================================================================

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
      \ 'quickrun' : "'Quickrun'",
      \ 'dictionary' : "exists('b:dictionary.input') ? b:dictionary.input : default",
      \ 'calendar' : "strftime('%Y/%m/%d')",
      \ 'thumbnail' : "exists('b:thumbnail.status') ? b:thumbnail.status : 'Thumbnail'",
      \ }
let s:f = [ 'ControlP', '__Tagbar__', 'vimfiler', 'unite', 'vimshell', 'dictionary', 'thumbnail' ]
function! lightline_powerful#filename()
  let f = expand('%:t')
  if has_key(b:, 'lightline_filename') && get(b:, 'lightline_filename_', '') ==# f . &mod . &ma && index(s:f, &ft) < 0 && index(s:f, f) < 0
    return b:lightline_filename
  endif
  let b:lightline_filename_ = f . &mod . &ma
  let default = join(filter([&ro ? "\u2b64" : '', f, &mod ? '+' : &ma ? '' : '-'], 'len(v:val)'), ' ')
  let b:lightline_filename = f =~# '^NERD_tree' ? '' : f =~# '^\[preview' ? 'Preview' : eval(get(s:e, &ft, get(s:e, f, 'default')))
  return b:lightline_filename
endfunction

function! lightline_powerful#fugitive()
  if has_key(b:, 'lightline_fugitive')
    if reltimestr(reltime(b:lightline_fugitive_)) =~# '^\s*\d\.'
      return b:lightline_fugitive
    endif
  endif
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let _ = fugitive#head()
      let b:lightline_fugitive = strlen(_) ? "\u2b60 "._ : ''
      let b:lightline_fugitive_ = reltime()
      return b:lightline_fugitive
    endif
  catch
  endtry
  return ''
endfunction

function! lightline_powerful#fileformat()
  return winwidth(0) > 70 ? &ff : ''
endfunction

function! lightline_powerful#filetype()
  return winwidth(0) > 70 ? (strlen(&ft) ? &ft : 'no ft') : ''
endfunction

function! lightline_powerful#fileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! lightline_powerful#ctrlpmark()
  if expand('%:t') !=# 'ControlP'
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

let s:m = { 'ControlP': 'CtrlP', '__Tagbar__': 'Tagbar', '__Gundo__': 'Gundo', '__Gundo_Preview__': 'Gundo Preview'}
let s:p = { 'unite': 'Unite', 'vimfiler': 'VimFiler', 'vimshell': 'VimShell', 'quickrun': 'Quickrun', 'dictionary': 'Dictionary', 'calendar': 'Calendar', 'thumbnail': 'Thumbnail' }
function! lightline_powerful#mode()
  return get(s:m, expand('%:t'), get(s:p, &ft, winwidth(0) > 60 ? lightline#mode() : ''))
endfunction

let g:tagbar_status_func = 'lightline_powerful#TagbarStatusFunc'
function! lightline_powerful#TagbarStatusFunc(current, sort, fname, ...) abort
  let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

let g:ctrlp_status_func = { 'main': 'lightline_powerful#CtrlPStatusFunc_1', 'prog': 'lightline_powerful#CtrlPStatusFunc_2' }
function! lightline_powerful#CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! lightline_powerful#CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

function! lightline_powerful#tabreadonly(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&readonly') ? "\u2b64" : ''
endfunction

function! lightline_powerful#tabfilename(n)
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
  return get(s:m, fname, get(s:p, ft, fname))
endfunction

function! lightline_powerful#syntasticerror()
  if exists('b:syntastic_loclist') && len(b:syntastic_loclist.errors())
    return substitute(substitute(b:syntastic_loclist.errors()[0].text, '%', '%%', 'g'), '\[.\{-}\]', '', 'g')
  endif
  return ''
endfunction

function! lightline_powerful#syntasticwarning()
  if exists('b:syntastic_loclist') && len(b:syntastic_loclist.warnings()) && !len(b:syntastic_loclist.errors())
    return substitute(substitute(b:syntastic_loclist.warnings()[0].text, '%', '%%', 'g'), '\[.\{-}\]', '', 'g')
  endif
  return ''
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
