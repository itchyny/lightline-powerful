" =============================================================================
" Filename: autoload/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2019/10/09 10:46:04.
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
function! lightline_powerful#filename() abort
  let f = expand('%:t')
  if has_key(b:, 'lightline_filename') && get(b:, 'lightline_filename_', '') ==# f . &mod . &ma && index(s:f, &ft) < 0 && index(s:f, f) < 0
    return b:lightline_filename
  endif
  let b:lightline_filename_ = f . &mod . &ma
  let default = join(filter([&ro ? 'RO' : '', f, &mod ? '+' : &ma ? '' : '-'], 'len(v:val)'), ' ')
  let b:lightline_filename = f ==# '' ? 'No Name' : f =~# '^\[preview' ? 'Preview' : eval(get(s:e, &ft, get(s:e, f, 'default')))
  return b:lightline_filename
endfunction

function! lightline_powerful#gitbranch() abort
  if has_key(b:, 'lightline_gitbranch') && reltimestr(reltime(b:lightline_gitbranch_)) =~# '^\s*0\.[0-3]'
    return b:lightline_gitbranch
  endif
  if exists('*gitbranch#name')
    let branch = gitbranch#name()
  else
    return ''
  endif
  let b:lightline_gitbranch = branch !=# '' ? branch : ''
  let b:lightline_gitbranch_ = reltime()
  return b:lightline_gitbranch
endfunction

let s:m = { 'ControlP': 'CtrlP', '__Tagbar__': 'Tagbar', '__Gundo__': 'Gundo', '__Gundo_Preview__': 'Gundo Preview', '[Command Line]': 'Command Line'}
let s:p = { 'unite': 'Unite', 'vimfiler': 'VimFiler', 'vimshell': 'VimShell', 'quickrun': 'Quickrun', 'dictionary': 'Dictionary', 'calendar': 'Calendar', 'thumbnail': 'Thumbnail', 'vimcalc': 'VimCalc', 'agit' : 'Agit', 'agit_diff' : 'Agit', 'agit_stat' : 'Agit', 'qf': 'QuickFix', 'github-dashboard': 'GitHub Dashboard' }
function! lightline_powerful#mode() abort
  if &ft ==# 'calendar'
    call lightline#link("nvV\<C-v>"[b:calendar.visual_mode()])
  elseif &ft ==# 'thumbnail'
    if !empty(b:thumbnail.view.visual_mode)
      call lightline#link(b:thumbnail.view.visual_mode)
    endif
  elseif expand('%:t') ==# 'ControlP'
    call lightline#link('iR'[get(g:lightline, 'ctrlp_regex', 0)])
  endif
  return get(s:m, expand('%:t'), get(s:p, &ft, lightline#mode()))
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
  return gettabwinvar(a:n, winnr, '&readonly') ? 'RO' : ''
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

let &cpo = s:save_cpo
unlet s:save_cpo
