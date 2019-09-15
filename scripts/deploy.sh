#!/usr/bin/env bash

# install gigalixir-cli
sudo apt-get install -y python-pip
sudo pip install --upgrade setuptools
sudo pip install gigalixir

# deploy
gigalixir login -e "$GIGALIXIR_EMAIL" -p "$GIGALIXIR_PASSWORD" -y
gigalixir git:remote $GIGALIXIR_APP_NAME
git push -f gigalixir HEAD:refs/heads/master
# some code to wait for new release to go live

# # set up ssh so we can migrate
# mkdir ~/.ssh
# printf "Host *\n StrictHostKeyChecking no" > ~/.ssh/config
# echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

# # migrate
# gigalixir ps:migrate -a $GIGALIXIR_APP_NAME