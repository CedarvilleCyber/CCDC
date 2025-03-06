#!/bin/bash
# Author: David Moore
# This is a script designed to colorize uncooperative shells.

echo "Configuring terminal to use xterm-256color..."
if ! grep -q 'export TERM=xterm-256color' ~/.bashrc
then
    echo 'export TERM=xterm-256color' >> ~/.bashrc
fi

echo "Forcibly coloring the prompt..."
sed -i '/#force_color_prompt=yes/ s/^#//' ~/.bashrc

# Apply the change in your current shell so you don't have to reload the shell
export TERM=xterm-256color

echo "Configuring tmux to use 256 colors..."
if infocmp tmux-256color > /dev/null 2>&1 && \
   ! grep -q 'set -g default-terminal "tmux-256color"' ~/.tmux.conf
then
    echo 'set -g default-terminal "tmux-256color"' >> ~/.tmux.conf
else
    echo "Falling back to screen-256color..."
    echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
fi

echo "Reloading shell configurations..."
source ~/.bashrc

echo "You should be able to use tmux with 256 colors now. You must reload tmux"
echo "for the changes to take effect. To reload, do this: tmux kill-server"
echo "To colorize the base terminal (before starting tmux), you must reload"
echo "the terminal by exiting it and logging in again. (Use the "exit" command)"