#!/usr/bin/env bash

# install gigalixir-cli
sudo apt-get install -y python-pip
sudo pip install --upgrade setuptools
sudo pip install gigalixir

# deploy
gigalixir login -e "$GIGALIXIR_EMAIL" -p "$GIGALIXIR_PASSWORD" -y
gigalixir git:remote $GIGALIXIR_APP_NAME
git push -f gigalixir HEAD:refs/heads/master

# run migrations
# NB: disable automatic run of migrations due to Gigalixir free tier constraints
# gigalixir run mix ecto.migrate