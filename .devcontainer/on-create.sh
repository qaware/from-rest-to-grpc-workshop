#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

export REPO_BASE=$PWD
export PATH="$PATH:$REPO_BASE/cli"

mkdir -p "$HOME/.ssh"

{
    # add cli to path
    echo "export PATH=\$PATH:$REPO_BASE/cli"

    echo "export REPO_BASE=$REPO_BASE"
    echo "compinit"
} >> "$HOME/.zshrc"

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

echo "generating completions"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"

echo "creating k3d cluster"
kic cluster create

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get clean -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
