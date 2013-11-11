" =============================================================================
" Filename: autoload/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/11/11 20:20:48.
" =============================================================================

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:filename_expr = {
      \ 'ControlP' : "get(g:lightline, 'ctrlp_item', expand('%:t'))",
      \ '__Tagbar__' : "get(g:lightline, 'fname', expand('%:t'))",
      \ '__Gundo__' : "''",
      \ '__Gundo_Preview__' : "''",
      \ 'vimfiler' : 'vimfiler#get_status_string()',
      \ 'unite' : 'unite#get_status_string()',
      \ 'vimshell' : "substitute(b:vimshell.current_dir,expand('~'),'~','')",
      \ 'dictionary' : "exists('b:dictionary.input') ? b:dictionary.input : ''",
      \ 'calendar' : "strftime('%Y/%m/%d')",
      \ 'thumbnail' : "'Thumbnail'",
      \ }
function! lightline_powerful#filename()
  let fname = expand('%:t')
  return fname =~# '^NERD_tree' ? '' :
        \ has_key(s:filename_expr, fname) ? eval(get(s:filename_expr, fname)) :
        \ has_key(s:filename_expr, &ft) ? eval(get(s:filename_expr, &ft)) :
        \ (&readonly ? "\u2b64 " : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ (&modified ? ' +' : &modifiable ? '' : ' -')
endfunction

function! lightline_powerful#fugitive()
  try
    if has_key(b:, 'lightline_fugitive')
      if reltimestr(reltime(b:lightline_fugitive_)) =~# '^\s*\d\.'
        return b:lightline_fugitive
      endif
    endif
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
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! lightline_powerful#filetype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
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

let s:fname_map = { 'ControlP': 'CtrlP', '__Tagbar__': 'Tagbar', '__Gundo__': 'Gundo', '__Gundo_Preview__': 'Gundo Preview'}
let s:ft_map = { 'unite': 'Unite', 'vimfiler': 'VimFiler', 'vimshell': 'VimShell', 'dictionary': 'Dictionary', 'calendar': 'Calendar', 'thumbnail': 'Thumbnail' }
function! lightline_powerful#mode()
  return get(s:fname_map, expand('%:t'), get(s:ft_map, &ft, winwidth(0) > 60 ? lightline#mode() : ''))
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
  return gettabwinvar(a:n, winnr, '&readonly') ? '⭤' : ''
endfunction

function! lightline_powerful#tabfilename(n)
  let bufnr = tabpagebuflist(a:n)[tabpagewinnr(a:n) - 1]
  let bufname = expand('#' . bufnr . ':t')
  let buffullname = expand('#' . bufnr . ':p')
  let bufnrs = filter(range(1, bufnr('$')), 'v:val != bufnr && len(bufname(v:val)) && bufexists(v:val) && buflisted(v:val)')
  let i = index(map(copy(bufnrs), 'expand("#" . v:val . ":t")'), bufname)
  let ft = gettabwinvar(a:n, tabpagewinnr(a:n), '&filetype')
  if strlen(bufname) && i >= 0 && map(bufnrs, 'expand("#" . v:val . ":p")')[i] != buffullname
    let fname = substitute(buffullname, '.*/\([^/]\+/\)', '\1', '')
  else
    let fname = bufname
  endif
  return get(s:fname_map, fname, get(s:ft_map, ft, strlen(fname) ? fname : '[No Name]'))
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
