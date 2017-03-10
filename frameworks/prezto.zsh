#!/usr/bin/env zsh

local prezto_install=${test_dir}/${0:t:r}

# download the repository
git clone --quiet --recursive https://github.com/sorin-ionescu/prezto.git "${prezto_install}/.zprezto" 2>/dev/null 1>&2 

# follow the install instructions
setopt EXTENDED_GLOB
for rcfile in "${prezto_install}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${prezto_install}/.${rcfile:t}"
done

# add the modules to the .zpreztorc file
rm -f ${prezto_install}/.zpreztorc
# In GNU and BSD, sed -i has different syntax, so it should be avoided.
sed -e "/'utility'/a\\
  'syntax-highlighting' 'history-substring-search' \\\\" \
  ${prezto_install}/.zprezto/runcoms/zpreztorc > ${prezto_install}/.zpreztorc

# prezto includes a .zlogin file, so source that once (needs interactive)
ZDOTDIR=${prezto_install} zsh -ic 'source ${ZDOTDIR}/.zlogin; exit'
