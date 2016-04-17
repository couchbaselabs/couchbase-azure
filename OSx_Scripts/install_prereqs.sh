#!/bin/sh
brew install node
sudo npm install -g azure-cli

#enable autocompletion
azure --completion >> ~/azure.completion.sh
echo 'source ~/azure.completion.sh' >> ~/.bash_profile

#try login
azure login