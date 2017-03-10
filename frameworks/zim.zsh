#!/usr/bin/env zsh

local zim_install=${test_dir}/${0:t:r}

# download the repository
git clone --quiet --recursive https://github.com/Eriner/zim.git "${zim_install}/.zim" 2>/dev/null 1>&2

# follow the install instructions
setopt EXTENDED_GLOB
for template_file ( ${zim_install}/.zim/templates/* ); do
  cat ${template_file} | tee -a ${zim_install}/.$(basename ${template_file}) > /dev/null
done

# no need to enable any extra modules; this is our baseline.

# source .zlogin per instructions
ZDOTDIR=${zim_install} zsh -ic 'source ${ZDOTDIR}/.zlogin; exit'
