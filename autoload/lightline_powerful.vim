" =============================================================================
" Filename: autoload/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/21 16:53:08.
" =============================================================================

let s:e = {
      \ 'vimfiler' : 'vimfiler#get_status_string()',
      \ 'unite' : 'unite#get_status_string()',
      \ 'quickrun' : "''",
      \ 'qf' : "''",
      \ 'dictionary' : "exists('b:dictionary.input') ? b:dictionary.input : default",
      \ 'calendar' : "strftime('%Y/%m/%d')",
      \ 'thumbnail' : "exists('b:thumbnail.status') ? b:thumbnail.status : 'Thumbnail'",
      \ 'agit' : "''",
      \ 'agit_diff' : "''",
      \ 'agit_stat' : "''",
      \ '[Command Line]': "'Command Line'",
      \ }
let s:f = [ 'vimfiler', 'unite', 'dictionary', 'thumbnail' ]
function! lightline_powerful#filename() abort
  let f = expand('%:t')
  if has_key(b:, 'lightline_filename') && get(b:, 'lightline_filename_', '') ==# f . &mod . &ma . &ft && (&ft ==# '' || index(s:f, &ft) < 0 && index(s:f, f) < 0)
    return b:lightline_filename
  endif
  let b:lightline_filename_ = f . &mod . &ma . &ft
  let default = join(filter([&ro ? 'RO' : '', f, &mod ? '+' : &ma ? '' : '-'], 'len(v:val)'), ' ')
  let b:lightline_filename = &ft ==# '' && f ==# '' ? 'No Name' : f =~# '^\[preview' ? 'Preview' : eval(get(s:e, &ft, get(s:e, f, 'default')))
  return b:lightline_filename
endfunction

let s:gitbranch_time = reltime()
function! lightline_powerful#gitbranch() abort
  if has_key(b:, 'lightline_gitbranch') && reltimefloat(reltime(s:gitbranch_time)) < 0.5
    return b:lightline_gitbranch
  endif
  let b:lightline_gitbranch = gitbranch#name()
  let s:gitbranch_time = reltime()
  return b:lightline_gitbranch
endfunction

let s:p = { 'unite': 'Unite', 'vimfiler': 'VimFiler', 'quickrun': 'Quickrun', 'dictionary': 'Dictionary', 'calendar': 'Calendar', 'thumbnail': 'Thumbnail', 'agit' : 'Agit', 'agit_diff' : 'Agit', 'agit_stat' : 'Agit', 'qf': 'QuickFix' }
function! lightline_powerful#mode() abort
  if &ft ==# 'calendar'
    call lightline#link("nvV\<C-v>"[b:calendar.visual_mode()])
  elseif &ft ==# 'thumbnail'
    if !empty(b:thumbnail.view.visual_mode)
      call lightline#link(b:thumbnail.view.visual_mode)
    endif
  endif
  return get(s:p, &ft, lightline#mode())
endfunction

function! lightline_powerful#tabreadonly(n) abort
  let winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, winnr, '&readonly') ? 'RO' : ''
endfunction

let s:buffer_count_by_basename = {}
augroup lightline_powerful_filenames
  autocmd!
  autocmd BufEnter,WinEnter,WinLeave * call s:update_bufnrs()
augroup END

function! s:update_bufnrs() abort
  let s:buffer_count_by_basename = {}
  let bufnrs = filter(range(1, bufnr('$')), 'buflisted(v:val) && bufexists(v:val) && len(bufname(v:val))')
  for name in map(bufnrs, 'expand("#" . v:val . ":t")')
    if name !=# ''
      let s:buffer_count_by_basename[name] = get(s:buffer_count_by_basename, name) + 1
    endif
  endfor
endfunction

function! lightline_powerful#tabfilename(n) abort
  let bufnr = tabpagebuflist(a:n)[tabpagewinnr(a:n) - 1]
  let bufname = expand('#' . bufnr . ':t')
  let ft = gettabwinvar(a:n, tabpagewinnr(a:n), '&ft')
  if get(s:buffer_count_by_basename, bufname) > 1
    let fname = substitute(expand('#' . bufnr . ':p'), '.*/\([^/]\+/\)', '\1', '')
  else
    let fname = bufname
  endif
  return fname =~# '^\[preview' ? 'Preview' : get(s:p, ft, fname)
endfunction
