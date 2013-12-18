" =============================================================================
" Filename: plugin/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2013/12/19 08:52:37.
" =============================================================================

let s:utf = &enc ==# 'utf-8' && &fenc ==# 'utf-8'

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:lightline = extend(get(g:, 'lightline', {}), {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], [ 'ctrlpmark' ] ],
      \   'right': [ [ 'syntastic_error', 'syntastic_warning', 'lineinfo'], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filename' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'percent' ] ]
      \ },
      \ 'tabline': {
      \   'left': [ [ 'tabs' ] ],
      \   'right': [ [ 'close' ] ]
      \ },
      \ 'tab': {
      \   'active': [ 'tabnum', 'readonly', 'filename', 'modified' ],
      \   'inactive': [ 'tabnum', 'readonly', 'filename', 'modified' ]
      \ },
      \ 'component': {
      \   'close': printf('%%999X %s ', has('multi_byte') && s:utf ? "\u2717" : 'x'),
      \ },
      \ 'component_function': {
      \   'fugitive': 'lightline_powerful#fugitive',
      \   'filename': 'lightline_powerful#filename',
      \   'fileformat': 'lightline_powerful#fileformat',
      \   'filetype': 'lightline_powerful#filetype',
      \   'fileencoding': 'lightline_powerful#fileencoding',
      \   'mode': 'lightline_powerful#mode',
      \   'ctrlpmark': 'lightline_powerful#ctrlpmark',
      \ },
      \ 'component_expand': {
      \   'syntastic_error': 'lightline_powerful#syntasticerror',
      \   'syntastic_warning': 'lightline_powerful#syntasticwarning',
      \ },
      \ 'component_type': {
      \   'syntastic_error': 'error',
      \   'syntastic_warning': 'warning',
      \ },
      \ 'tab_component_function': {
      \   'filename': 'lightline_powerful#tabfilename',
      \   'readonly': 'lightline_powerful#tabreadonly',
      \ },
      \ }, 'keep')

if s:utf
  call extend(g:lightline, {
      \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
      \ 'subseparator': { 'left': "\u2b81", 'right': "\u2b83" } })
endif

let &cpo = s:save_cpo
unlet s:save_cpo
