# vim-ripgrep

```vim
:Rg <string|pattern>
```

Word under cursor will be searched if no argument is passed to `Rg`

## Configuration


| Setting                | Default                 | Details
| -----------------------|-------------------------|----------
| `g:rg_binary`          | `rg`                    | path to rg
| `g:rg_format`          | `%f:%l:%c:%m`           | value of grepformat
| `g:rg_command`         | `g:rg_binary --vimgrep` | search command
| `g:rg_no_highlight`    | `undefined`             | true to disable match highlights
| `g:rg_highlight_type`  | `identifier`            | if `rg_highlight` is set, use this syntax color to highlight the result
| `g:rg_derive_root`     | `false`                 | true if you want to find project root from cwd
| `g:rg_root_types`      | `['.git']`              | list of files/dir found in project root
| `g:rg_window_location` | `botright`              | quickfix window location

## Keymaps

| Shortcut           | Action
| ------------------ | -----------------------------------------------------------
| `<C-e>`            | edit and exit quickfix window
| `<C-o>`            | preview/open file but leave focus in quickfix
| `<C-q>`            | close quickfix
| `<C-t>`            | open in new tab
| `<C-s>`            | open in new tab silently (stay focused in current window)
| `<C-x>`            | open in horizontal split
| `<C-v>`            | open in vertical split
