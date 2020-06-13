" =============================================================================
" File:          autoload/fzf_mru/mrufiles.vim
" Description:   Most Recently Used Files
" Author:        Pawel Bogut <github.com/pbogut>
" =============================================================================

function! fzf_mru#actions#params(params)
  let params = a:params
  if (len(params) && params[0] != '-')
    let params = '-q ' . shellescape(params)
  endif

  return params
endfunction

function! fzf_mru#actions#options() abort
  let options = '--prompt "MRU>"   --preview "bat --color=always --style=changes,grid --color always {2..-1} | head -200" --expect=ctrl-v,ctrl-x'
  if !empty(get(g:, 'fzf_mru_no_sort', 0))
    let options .= '--no-sort '
  endif
  return options
endfunction

  function! s:edit_file(lines)
    if len(a:lines) < 2 | return | endif

    let l:cmd = get({'ctrl-x': 'split',
                 \ 'ctrl-v': 'vertical split',
                 \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')

    for l:item in a:lines[1:]
      let l:pos = strridx(l:item, ' ')
      let l:file_path = l:item[pos+1:-1]
      execute 'silent '. l:cmd . ' ' . l:file_path
    endfor
  endfunction

function! fzf_mru#actions#mru(...) abort
  let params = fzf_mru#actions#params(get(a:, 001, ''))
  let options = extend(
        \   {
        \     'source': fzf_mru#mrufiles#source(),
        \      'sink*': function('s:edit_file'),
        \     'options': fzf_mru#actions#options() . params,
        \   },
        \   get(a:, 002, {})
        \ )

  let extra = extend(copy(get(g:, 'fzf_layout', {'down': '~40%'})), options)

  call fzf#run(fzf#wrap('name', extra, 0))
endfunction
