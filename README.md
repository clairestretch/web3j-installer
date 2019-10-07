# web3j-installer
Command line installer for Web3j

### How to (UNIX):
In a terminal, run the following command:

`curl -L https://get.web3j.io | sh ; source ~/.web3j/source.sh `

This script will not work if Web3j has been installed using Homebrew on macOS.

### How to (Windows):
In PowerShell, run the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/web3j/web3j-installer/master/installer.ps1'))`
