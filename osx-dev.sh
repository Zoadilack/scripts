#!/bin/sh
#
# Setup for a fresh developer workstation.
#
#  git clone git@bitbucket.org:zoadilack/zoadilack-scripts.git
#  bash zoadilack-scripts/osx-dev.sh
#

INSTALL_DIR=/usr/local
REPO_DIR=${INSTALL_DIR}/zoadilack
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
    echo "Developer Tools not installed; let's do that now" 
    echo "Please click 'Install' on the popup and follow the prompts"
    xcode-select --install
    echo "Successfully installed Develper Tools"
fi

if /usr/bin/xcrun clang 2>&1 | grep license &> /dev/null; then
    echo "We are automatically accepting the XCode License for you.."
    sudo xcodebuild -license accept
    echo "License agreement registered"
else
    echo "Developer Tools license ok"
fi

if type pip &> /dev/null; then
  echo "You've got pip..."
else
  sudo easy_install pip
fi

if type python &> /dev/null; then
  echo "Python found"
else
  brew install python
fi

if type composer &> /dev/null; then
  echo "Composer found, let's see if we need to update.."
  composer self-update
else
  echo "Installing composer"
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
fi

if type brew &> /dev/null; then
  echo "Awesome! Homebrew is installed already!"
else
  echo "Homebrew is not installed; let's do that now"
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "Successfully installed Homebrew"
fi


if brew tap | grep caskroom &> /dev/null; then
  echo "Skipping Brew Cask"
else
  echo "Brew Cask is not installed; let's do that now"
  echo "Installing Brew Cask "
  brew tap caskroom/cask
  echo "Successfully installed Brew Cask"
fi


if type git &> /dev/null; then
  echo "Skipping git"
else
  echo "Installing Git "
  brew install git
  echo "Successfully installed Git"
fi


if type ansible &> /dev/null; then
  echo "Skipping Ansible"
else
  echo "Installing Ansible "
  brew install ansible
  echo "Successfully installed Ansible"
fi


if type vagrant &> /dev/null; then
  echo "Skipping Vagrant"
else
  echo "Installing Vagrant"
  brew cask install vagrant
  echo "Successfully installed Vagrant"
fi

if type virtualbox &> /dev/null; then
  echo "Skipping Virtualbox"
else
  echo "Installing VirtualBox"
  brew cask install virtualbox
  echo "Successfully installed VirtualBox"
fi


if type drush &> /dev/null; then
  echo "Skipping Drush"
else
  echo "Installing Drush"
  # Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
  php -r "readfile('http://files.drush.org/drush.phar');" > drush
  # Or use our upcoming release: php -r "readfile('http://files.drush.org/drush-unstable.phar');" > drush

  # Test your install.
  php drush core-status

  # Make `drush` executable as a command from anywhere. Destination can be anywhere on $PATH.
  chmod +x drush
  sudo mv drush /usr/local/bin

  # Optional. Enrich the bash startup file with completion and aliases.
  drush init
fi

if type wp &> /dev/null; then
  echo "wp-cli found, checking for updates"
  wp --allow-root cli update
else
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
fi

# Install PHP7
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew unlink php56
brew install php70

VIRTUALBOX_VERSION=$(vboxmanage --version | cut -b1);
if [ ${VIRTUALBOX_VERSION} -ne 5 ]; then
    echo
    echo "ERROR: Your VirtualBox is too old; please upgrade to version 5"
    echo
    echo "you may be able to do this by running:"
    echo "    brew cask install virtualbox"
    echo
    exit 1;
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

# Install AWS CLI
if type aws &> /dev/null; then
  echo "You never cease to amaze! AWS CLI is installed; let's check for an update!"
  sudo pip install --upgrade awscli
else
  echo "Installing AWS CLI"
  sudo pip install awscli --ignore-installed six
fi

# Install Vagrant plugins
sudo vagrant plugin install ansible
sudo vagrant plugin install landrush

# Install some packages for Homebrew
brew install colordiff 
brew install tig 
brew install macvim
brew install gnupg

# Install some Ruby gems
sudo gem install sass
sudo gem install compass

# Update all composer dependencies/libraries.
echo "Updating Composer stuff!"
composer global update
