#!/bin/bash
set -e
gcc -o catall catall.c
sudo chown root:root catall
sudo chmod 4755 catall
command -v zsh >/dev/null || sudo apt-get install -y zsh
sudo ln -sf /usr/bin/zsh /bin/sh
