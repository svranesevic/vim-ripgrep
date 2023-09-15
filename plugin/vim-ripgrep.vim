if exists('g:loaded_rg') || &cp
  finish
endif

let g:loaded_rg = 1

if !exists('g:rg_binary')
  let g:rg_binary = 'rg'
endif

if !exists('g:rg_format')
  let g:rg_format = "%f:%l:%c:%m"
endif

if !exists('g:rg_command')
  let g:rg_command = g:rg_binary . ' --vimgrep --no-heading --with-filename --line-number --column --color=never --ignore-vcs --hidden -g "!.git/"'
endif

if !exists('g:rg_root_types')
  let g:rg_root_types = ['.git']
endif

if !exists('g:rg_window_location')
  let g:rg_window_location = 'botright'
endif

if !exists('g:rg_no_highlight')
  let g:rg_highlight = 1
endif

if !exists('g:rg_highlight_type')
  let g:rg_highlight_type = 'keyword'
endif

fun! s:RgApplyKeyboardShortcuts()
  " edit and exit quickfix
  nnoremap <silent> <buffer> <C-e> <CR><C-w><C-w>:cclose<CR>
  " preview silently
  nnoremap <silent> <buffer> <C-o> <CR>:copen<CR>

  " new tab
  nnoremap <silent> <buffer> <C-t> <C-w><CR><C-w>T
  " new tab silently (stay focused in quickfix)
  nnoremap <silent> <buffer> <C-s> <C-w><CR><C-w>TgT<C-W><C-W>

  " horizontal split
  nnoremap <silent> <buffer> <C-x> <C-W><CR><C-w>K<C-w>b

  " vertical splut
  nnoremap <silent> <buffer> <C-v> :let b:height=winheight(0)<CR><C-w><CR><C-w>H:copen<CR><C-w>J:exe printf(":normal %d\<lt>c-w>_", b:height)<CR>
endfun

fun! s:Rg(args)
  call s:RgGrepContext(function('s:RgSearch'), a:args)
endfun

fun! s:RgCword()
  call s:RgGrepContext(function('s:RgSearch'), "-w " . expand('<cword>'))
endfun

fun! s:RgVisual(args) range
  call s:RgGrepContext(function('s:RgSearch'), '"' . s:RgGetVisualSelection() . '"' . ' ' . a:args)
endfun

fun! s:RgGetVisualSelection()
  " Why is this not a built-in Vim script function?!
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfun

fun! s:RgSearchTerm(txt)
  if empty(a:txt)
    return expand("<cword>")
  else
    return a:txt
  endif
endfun

fun! s:RgSearch(txt)
  let l:rgopts = ' '
  if &smartcase == 1
    let l:rgopts = l:rgopts . '-S '
  endif
  " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
  silent! exe 'grep! ' . l:rgopts . escape(a:txt, "#%|")
  if len(getqflist())
    exe g:rg_window_location 'copen'
    redraw!
    if exists('g:rg_highlight')
      call s:RgHighlight(a:txt)
    endif
  else
    cclose
    redraw!
    echo "No match found for " . a:txt
  endif
  call s:RgApplyKeyboardShortcuts()
endfun

fun! s:RgGrepContext(search, txt)
  let l:grepprgb = &grepprg
  let l:grepformatb = &grepformat
  let &grepprg = g:rg_command
  let &grepformat = g:rg_format
  let l:te = &t_te
  let l:ti = &t_ti
  let l:shellpipe_bak=&shellpipe
  set t_te=
  set t_ti=
  if !has("win32")
    let &shellpipe="2>&1 | cat >"
  endif

  if exists('g:rg_derive_root')
    call s:RgPathContext(a:search, a:txt)
  else
    call a:search(a:txt)
  endif

  let &shellpipe=l:shellpipe_bak
  let &t_te=l:te
  let &t_ti=l:ti
  let &grepprg = l:grepprgb
  let &grepformat = l:grepformatb
endfun

fun! s:RgPathContext(search, txt)
  let l:cwdb = getcwd()
  exe 'lcd '.s:RgRootDir()
  call a:search(a:txt)
  exe 'lcd '.l:cwdb
endfun

fun! s:RgHighlight(txt)
  call matchadd(g:rg_highlight_type, a:txt)
endfun

fun! s:RgRootDir()
  let l:cwd = getcwd()
  let l:dirs = split(getcwd(), '/')

  for l:dir in reverse(copy(l:dirs))
    for l:type in g:rg_root_types
      let l:path = s:RgMakePath(l:dirs, l:dir)
      if s:RgHasFile(l:path.'/'.l:type)
        return l:path
      endif
    endfor
  endfor
  return l:cwd
endfun

fun! s:RgMakePath(dirs, dir)
  return '/'.join(a:dirs[0:index(a:dirs, a:dir)], '/')
endfun

fun! s:RgHasFile(path)
  return filereadable(a:path) || isdirectory(a:path)
endfun

fun! s:RgShowRoot()
  if exists('g:rg_derive_root')
    echo s:RgRootDir()
  else
    echo getcwd()
  endif
endfun

command! -nargs=* -complete=file -bang        Rg         :call s:Rg(<q-args>)
command! -nargs=0                -bang        RgCword    :call s:RgCword()
command! -nargs=* -complete=file -bang -range RgVisual   :call s:RgVisual(<q-args>)
