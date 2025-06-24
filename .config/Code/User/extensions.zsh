#! /bin/zsh

extensions=(
  # //TODO: must install this manually, it fails if you install with code --install-extension for some reason
  # I believe this is because cursor and vscode have different extension marketplaces
  # ldez.ignore-files

  # Formatting
  esbenp.prettier-vscode
  ms-python.black-formatter

  # Syntax Highlighting
  prisma.prisma
  naumovs.color-highlight

  # Language Servers
  redhat.vscode-yaml
  bradlc.vscode-tailwindcss
  ms-python.vscode-pylance
  ms-python.debugpy
  ms-python.python
  dbaeumer.vscode-eslint

  # Aesthetics
  pkief.material-icon-theme
  yoavbls.pretty-ts-errors
  oderwat.indent-rainbow
  zhuangtongfa.material-theme # one dark pro

  # File Handlers
  tomoki1207.pdf
  mechatroner.rainbow-csv
  janisdd.vscode-edit-csv
  grapecity.gc-excelviewer

  # Git
  coderabbit.coderabbit-vscode
  github.vscode-pull-request-github
  mhutchie.git-graph

  # Markdown
  # yzhang.markdown-all-in-one
  # ozaki.markdown-github-dark
  # bierner.markdown-checkbox

  # Misc
  anthropic.claude-code
)

function install_extensions() {
  config_extensions=($(printf '%s\n' "${extensions[@]}" | sort))

  # Get currently installed extensions
  current_extensions=($(code --list-extensions | sort))

  # Find untracked extensions (installed but not in config)
  untracked_extensions=()
  for ext in "${current_extensions[@]}"; do
    if [[ ! " ${config_extensions[*]} " =~ " ${ext} " ]]; then
      untracked_extensions+=("$ext")
    fi
  done
  if [[ ${#untracked_extensions[@]} -gt 0 ]]; then
    echo "=== UNTRACKED EXTENSIONS ==="
    printf '%s\n' "${untracked_extensions[@]}"
    echo ""
  fi

  # Install missing extensions
  extensions_to_install=()
  for ext in "${config_extensions[@]}"; do
    if [[ ! " ${current_extensions[*]} " =~ " ${ext} " ]]; then
      extensions_to_install+=("$ext")
    fi
  done
  if [[ ${#extensions_to_install[@]} -gt 0 ]]; then
    for extension in "${extensions_to_install[@]}"; do
      code --install-extension "$extension" > /dev/null
      echo "✅ Installed $extension"
    done
  fi
}

install_extensions