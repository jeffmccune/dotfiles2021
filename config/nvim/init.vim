if !empty($HOME)
  let g:python3_host_prog = "$HOME/.dotfiles2021-python/bin/python3"
  " Node is installed by the setup_server script and isolated by asdf
  let g:node_host_prog = "$HOME/.dotfiles2021/scripts/node"
  let g:coc_node_path = "$HOME/.dotfiles2021/scripts/node"
  let g:coc_install_yarn_cmd = "$HOME/.dotfiles2021/scripts/yarn"
endif

let g:UltiSnipsSnippetDirectories = ['~/.config/nvim/UltiSnips', 'UltiSnips']
:so ~/.vimrc
