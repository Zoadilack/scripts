#!/bin/sh
#
# Installs the default Zoadilack development environment:
#
#  git clone git@github.com:zoadilack/scripts.git && cd scripts && bash osx-dev.sh
#

INSTALL_DIR=/usr/local
REPO_DIR=${INSTALL_DIR}/zoadilack-scripts
DESIRED_ROLES_PATH=${REPO_DIR}/ansible-roles

if [ -w ${INSTALL_DIR} ]; then
  echo "Write permission to ${INSTALL_DIR} verified"
else
  echo "You cannot write to ${INSTALL_DIR}. Changing owner...."
  sudo chown $(whoami):admin ${INSTALL_DIR}
fi

if xcode-select -p &> /dev/null; then
    echo "Developer Tools located"
else
    xcode-select --install
fi

if /usr/bin/xcrun clang 2>&1 | grep license &> /dev/null; then
    sudo xcodebuild -license accept
else
    echo "Developer Tools license ok"
fi

if type composer &> /dev/null; then
  composer self-update
else
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
fi

if type brew &> /dev/null; then
  echo "Awesome! Homebrew is installed already!"
else
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew uninstall --force brew-cask; brew update
fi

brew update

brew ls --versions python && brew upgrade python || brew install python
brew ls --versions git && brew upgrade git || brew install git
brew ls --versions ansible && brew upgrade ansible || brew install ansible

if type vagrant &> /dev/null; then
  echo "Exquisite! Vagrant is installed already!"
else
  brew cask install vagrant
fi

vboxmanage list runningvms | sed -r 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate

if type virtualbox &> /dev/null; then
  echo "Astounding! VirtualBox is installed already!"
else
  brew install Caskroom/cask/virtualbox-extension-pack
fi

if type drush &> /dev/null; then
  echo "Shame on me for doubting you. Drush is installed!"
else
  php -r "readfile('http://files.drush.org/drush.phar');" > drush
  php drush core-status
  chmod +x drush
  sudo mv drush /usr/local/bin

  # Optional. Enrich the bash startup file with completion and aliases.
  drush init
fi

if type wp &> /dev/null; then
  wp --allow-root cli update
else
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
fi

VIRTUALBOX_VERSION=$(vboxmanage --version | cut -b1);
if [ ${VIRTUALBOX_VERSION} -ne 5 ]; then
  brew uninstall Caskroom/cask/virtualbox-extension-packinstall && brew install Caskroom/cask/virtualbox-extension-pack
else
  brew install Caskroom/cask/virtualbox-extension-pack
fi

if [ -f ~/.ansible.cfg ]; then
  echo "Excellent! You already have the ansible configuration file"
  CURRENT_ROLES_PATH=`cat ~/.ansible.cfg | grep roles_path | cut -d'=' -f 2 | tr -d ' '`
  if [ ${CURRENT_ROLES_PATH} = ${DESIRED_ROLES_PATH} ]; then
      echo "OK! roles_path looks good"
  else
      echo "Action required! Change your Ansible roles_path to ${DESIRED_ROLES_PATH}"
  fi
else
  cat > ~/.ansible.cfg << END_TEXT
[ssh_connection]
scp_if_ssh = True
[defaults]
retry_files_enabled = False # Do not create them
roles_path = ${DESIRED_ROLES_PATH}
END_TEXT
  echo "Ansible configuration file created"
fi

if type pip &> /dev/null; then
  pip install --upgrade pip
else
  sudo easy_install pip
fi

# Install AWS CLI
if type aws &> /dev/null; then
  sudo pip install --upgrade awscli
else
  sudo pip install awscli --ignore-installed six
fi

# Install Vagrant plugins
sudo vagrant plugin install ansible
sudo vagrant plugin install vagrant-vbguest
sudo vagrant plugin install vagrant-docker-compose 
sudo vagrant plugin install vagrant-hostsupdater

# Install some packages for Homebrew
brew ls --versions php56 && brew unlink php56
brew ls --versions php71 && brew upgrade php71 || brew install php71
brew ls --versions docker && brew upgrade docker || brew install docker
brew ls --versions docker-clean && brew upgrade docker-clean || brew install docker-clean
brew ls --versions node && brew upgrade node || brew install node
brew ls --versions colordiff && brew upgrade colordiff || brew install colordiff
brew ls --versions tig && brew upgrade tig || brew install tig
brew ls --versions macvim && brew upgrade macvim || brew install macvim
brew ls --versions gnupg && brew upgrade gnupg || brew install gnupg
brew ls --versions zsh && brew upgrade zsh || brew install zsh
brew ls --versions zsh-completions && brew upgrade zsh-completions || brew install zsh-completions
brew ls --versions homebrew/php/php71-xdebug && brew upgrade homebrew/php/php71-xdebug || brew install homebrew/php/php71-xdebug

# Install some Node packages
npm install -g aglio grunt-cli

# Install some Ruby gems
sudo gem install sass
sudo gem install compass

# Update all composer dependencies/libraries.
composer global update

# Update Terminal Syntax Highlighting
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Done"

brew doctor