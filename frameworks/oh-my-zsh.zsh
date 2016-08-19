#!/usr/bin/env zsh

local omz_install=${test_dir}/oh-my-zsh

# download the install script
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh > ${omz_install}/install.sh


# before we run the script, we're going to change where oh-my-zsh installs.
sed -i "s,ZSH=~/.oh-my-zsh,ZSH=${omz_install}/.oh-my-zsh,g" ${omz_install}/install.sh
sed -i "s,~/.zshrc,${omz_install}/.zshrc,g" ${omz_install}/install.sh
# also remove the automatic-start of the new terminal
sed -i 's/\<env zsh\>//g' "${omz_install}/install.sh"
# silence the git clone output
sed -i 's/env git clone/env git clone --quiet/g' ${omz_install}/install.sh
# remove the chsh crap
sed -i '83,96d' ${omz_install}/install.sh

# we don't need auto-update stuff
DISABLE_AUTO_UPDATE=true

# permit to execute the benchmark even if it run on zsh with oh-my-zsh
ZSH="${omz_install}/.oh-my-zsh"

# run though sh as per the instructions
sh ${omz_install}/install.sh 1> /dev/null

# grab zsh-syntax-highlighting
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${omz_install}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# replace the plugin string with the selected plugins
sed -i 's/^plugins=.*/plugins=(git history-substring-search zsh-syntax-highlighting)/g' ${omz_install}/.zshrc
