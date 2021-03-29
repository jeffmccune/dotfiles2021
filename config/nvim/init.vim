if !empty($HOME)
  let g:python3_host_prog = "$HOME/.dotfiles2021-python/bin/python3"
  " Node is installed by the setup_server script
  let g:coc_node_path = "$HOME/.dotfiles2021-node/versions/node/v15.12.0/bin/node"
endif

let g:UltiSnipsSnippetDirectories = ['~/.config/nvim/UltiSnips', 'UltiSnips']
:so ~/.vimrc
