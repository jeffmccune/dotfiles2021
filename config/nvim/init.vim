" ${DOTDIR}/bin/nvim places python3 and node in the PATH
if !empty($DOT_PYTHON)
  let g:python3_host_prog = "$DOT_PYTHON"
endif
if !empty($DOT_NODE)
  let g:node_host_prog = "$DOT_NODE"
  let g:coc_node_path = "$DOT_NODE"
endif
if !empty($DOT_YARN)
  let g:coc_install_yarn_cmd = "$DOT_YARN"
endif

let g:UltiSnipsSnippetDirectories = ['~/.config/nvim/UltiSnips', 'UltiSnips']
:so ~/.vimrc
