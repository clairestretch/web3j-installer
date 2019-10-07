#!/bin/bash
web3j_version="4.5.5"
installed_flag=0

check_if_installed() {
  if [ -x "$(command -v web3j)" ] &>/dev/null; then
    printf 'A Web3j installation exists on your system: '
    installed_flag=1
  fi
}

install_web3j() {
  echo "Downloading Web3j ..."
  mkdir "$HOME/.web3j"
  if [[ $(curl --write-out %{http_code} --silent --output /dev/null "https://github.com/web3j/web3j-cli/releases/download/v${web3j_version}/web3j-${web3j_version}.tar") -eq 302 ]]; then
    curl -# -L -o "$HOME/.web3j/web3j-${web3j_version}.tar" "https://github.com/web3j/web3j-cli/releases/download/v${web3j_version}/web3j-${web3j_version}.tar"
    echo "Installing Web3j..."
    tar -xf "$HOME/.web3j/web3j-${web3j_version}.tar" -C "$HOME/.web3j"
    echo "export PATH=\$PATH:$HOME/.web3j/web3j-${web3j_version}/bin" >"$HOME/.web3j/source.sh"
    chmod +x "$HOME/.web3j/source.sh"
    echo "Removing downloaded archive..."
    rm "$HOME/.web3j/web3j-${web3j_version}.tar"
  else
    echo "Looks like there was an error while trying to download web3j"
    exit 0
  fi
}

check_version() {
  version_string=$(web3j version | grep Version | awk -F" " '{print $NF}')
  echo "$version_string"
  if [[ $version_string < $web3j_version ]]; then
    echo "Your Web3j version is not up to date."
    get_user_input
  else
    echo "You have the latest version of Web3j. Exiting."
    exit 0
  fi
}

get_user_input() {
  while read -p "Would you like to update Web3j ? [y]es | [n]o : " user_input; do
    case $user_input in
    y)
      echo "Updating Web3j ..."
      break
      ;;
    n)
      echo "Aborting instalation ..."
      exit 0
      ;;
    esac
  done
}

check_if_web3j_homebrew() {
  if (command -v brew && ! (brew info web3j | grep "Not installed") &>/dev/null); then
    echo "Looks like Web3j is installed with Homebrew. Please use Homebrew to update. Exiting."
    exit 0
  fi
}

clean_up() {
  if [ -d "$HOME/.web3j" ]; then
    rm -r "$HOME/.web3j" &>/dev/null
    echo "Deleting older installation ..."
  fi
}

source_web3j() {
  SOURCE_WEB3J="\n[ -s \"$HOME/.web3j/source.sh\" ] && source \"$HOME/.web3j/source.sh\""

  files=("$HOME/.bashrc")

  if [ -f "$HOME/.bash_profile" ]; then
    files+=("$HOME/.bash_profile")
  elif [ -f "$HOME/.bash_login" ]; then
    files+=("$HOME/.bash_login")
  elif [ -f "$HOME/.profile" ]; then
    files+=("$HOME/.profile")
  else
    files+=("$HOME/.bash_profile")
  fi

  for file in "${files[@]}"; do
    touch "${file}"
    if ! grep -qc '.web3j/source.sh' "${file}"; then
      echo "Adding source string to ${file}"
      printf "$SOURCE_WEB3J\n" >>"${file}"
    else
      echo "Skipped update of ${file} (source string already present)"
    fi
  done

  if [ -f "$(command -v zsh 2>/dev/null)" ]; then
    file="$HOME/.zshrc"
    touch ${file}
    if ! grep -qc '.web3j/source.sh' "${file}"; then
      echo "Adding source string to ${file}"
      printf "$SOURCE_WEB3J\n" >>"${file}"
    else
      echo "Skipped update of ${file} (source string already present)"
    fi
  fi
}
completed() {
  echo "Web3j was succesfully installed"
  echo "To get started you will need Web3j's bin directory in your PATH enviroment variable."
  echo "When you open a new terminal window this will be done automatically." 
  echo "To see what web3j's CLI can do you can check the documentation bellow."
  echo "https://docs.web3j.io/command_line_tools/ "
  echo "To use web3j in your current shell run: source \$HOME/.web3j/source.sh "
  exit 0
}

main() {
  check_if_installed
  if [ $installed_flag -eq 1 ]; then
    check_if_web3j_homebrew
    check_version
    clean_up
    install_web3j
    source_web3j
    completed
  else
    clean_up
    install_web3j
    source_web3j
    completed
  fi
}

main
