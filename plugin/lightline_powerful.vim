" =============================================================================
" Filename: plugin/lightline_powerful.vim
" Author: itchyny
" License: MIT License
" Last Change: 2019/12/23 10:49:49.
" =============================================================================

if exists('g:loaded_lightline_powerful') || v:version < 700
  finish
endif
let g:loaded_lightline_powerful = 1

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
      \   'right': []
      \ },
      \ 'tab': {
      \   'active': [ 'tabnum', 'readonly', 'filename', 'modified' ],
      \   'inactive': [ 'tabnum', 'readonly', 'filename', 'modified' ]
      \ },
      \ 'component': {
      \   'lineinfo': '%3l:%-2c%<',
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

let &cpo = s:save_cpo
unlet s:save_cpo
