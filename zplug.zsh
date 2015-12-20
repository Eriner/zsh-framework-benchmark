#!/usr/bin/env zsh

local zplug_install="${test_dir}/zplug"

mkdir -p ${zplug_install}

# download framework
curl -sfLo ${zplug_install}/.zplug/zplug --create-dirs https://git.io/zplug

# add modules to .zshrc

# NOTE: we don't want ${ZDOTDIR} to expand here; it will expand in the .zshrc
print 'source ${ZDOTDIR}/.zplug/zplug \
zplug "zsh-users/zsh-history-substring-search" \
zplug "zsh-users/zsh-completions" \
zplug "zsh-users/zsh-syntax-highlighting", nice:10
zplug load' >>! ${zplug_install}/.zshrc

# set zplug home
# NOTE: this seems to be broken for reasons I do not understand.
#       zplug seems to only use this variable to derrive its location, but
#       it does not propperly load plugins from here (~/.zplug works)
#
#       As a work-aruond, just let it do what it wants to ~/.zplug, and clean up.
#       THIS IS NOT IDEAL.
#ZPLUG_HOME=${zplug_install}/.zplug

# install the plugins
ZDOTDIR=${zplug_install} zsh -ic "zplug install; exit"
