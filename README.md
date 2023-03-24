# operator-sort

**operator-sort** is a Vim plugin to provide operators to sort a text. As a sort method, alphabetical order and numerical order are available.

## Requirements

- Vim 8.0 or later
- [operator-user](https://github.com/kana/vim-operator-user) 0.1.0 or later

## Usage

The plugin does not provide any default key mappings. You have to configure key mappings like the following:

```vim
" With "!" the order is reversed.
map <Leader>s  <Plug>(operator-sort)
map <Leader>S  <Plug>(operator-sort!)
map <Leader>n  <Plug>(operator-sort-numeric)
map <Leader>N  <Plug>(operator-sort-numeric!)
```

## Documentation

You can access the [documentation](https://github.com/emonkak/vim-operator-sort/blob/master/doc/operator-sort.txt) from within Vim using `:help operator-sort`.
