#!/usr/bin/env zsh

# initialize the framework

# install location
omz_install='/tmp/zsh-benchmark/oh-my-zsh'

mkdir -p ${omz_install}

# download the install script
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh > ${omz_install}/install.sh


# before we run the script, we're going to change where oh-my-zsh installs.
sed -i 's/ZSH=~\/.oh-my-zsh/ZSH=\/tmp\/zsh-benchmark\/oh-my-zsh\/.oh-my-zsh/g' ${omz_install}/install.sh
sed -i 's/~\/.zshrc/\/tmp\/zsh-benchmark\/oh-my-zsh\/.zshrc/g' ${omz_install}/install.sh
# also remove the automatic-start of the new terminal
sed -i 's/\<env zsh\>//g' ${omz_install}/install.sh

# run though sh as per the instructions
sh ${omz_install}/install.sh

# grab zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${omz_install}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# replace the plugin string with the selected plugins
sed -i 's/^plugins=.*/plugins=(git history-substring-search zsh-syntax-highlighting)/g' ${omz_install}/.zshrc
