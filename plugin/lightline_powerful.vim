" =============================================================================
" Filename: plugin/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2017/05/28 02:28:42.
" =============================================================================

if exists('g:loaded_lightline_powerful') || v:version < 700
  finish
endif
let g:loaded_lightline_powerful = 1

let s:utf = &enc ==# 'utf-8' && &fenc ==# 'utf-8'

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:lightline = extend(get(g:, 'lightline', {}), {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
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
      \   'lineinfo': '%3l:%-2c',
      \ },
      \ 'component_function': {
      \   'gitbranch': 'lightline_powerful#gitbranch',
      \   'filename': 'lightline_powerful#filename',
      \   'mode': 'lightline_powerful#mode',
      \ },
      \ 'component_function_visible_condition': {
      \   'filename': 'get(b:,"lightline_filename","")!=#""',
      \   'mode': '1',
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
