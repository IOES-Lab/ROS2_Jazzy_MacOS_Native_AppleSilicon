#!/bin/bash
################################################################################
########### ROS2 Jazzy Installation Script for MacOS (Apple Silicon) ###########
################################################################################
# Author: Choi Woen-Sug (Github: woensugchoi)
# First Created: 2024.6.15
################################################################################
# To Run this script, you need to have the following installed:
# - XCode (https://apps.apple.com/app/xcode/id497799835)
# - Command Line Tools (https://developer.apple.com/download/more/)
#   xcode-select --install
#   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
#   sudo xcodebuild -license
# - Brew
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#   (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
#    eval "$(/opt/homebrew/bin/brew shellenv)"
#
# Also, need to make this script executable
# chmod +x install.sh
################################################################################

# ------------------------------------------------------------------------------
# Installation Configuration 
# ------------------------------------------------------------------------------
ROS_INSTALL_ROOT="ros2_jazzy"

# Print welcome message
echo -e "\032[92m"
echo "---------------------------------------------------------"
echo "| 👋 Welcome to the MacOS installation of ROS2 Jazzy 🚧 |"
echo "| 🍎 (Apple Silicon) + 🤖 = 🚀❤️       by Choi Woen-Sug  |"
echo "---------------------------------------------------------"
echo -e Target Installation Directory: "\033[94m$HOME/$ROS_INSTALL_ROOT\033[0m"
echo -e "\033[0m"

# ------------------------------------------------------------------------------
# Check System
echo -e "\033[34m### [1/5] Checking System Requirements\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
# Check XCode installation
if [ ! -e "/Applications/Xcode.app/Contents/Developer" ]; then
    echo -e "\033[31mError: Xcode is not installed. Please install Xcode through the App Store."
    echo -e "\033[31m       You can download it from: https://apps.apple.com/app/xcode/id497799835\033[0m"
    exit 1
else
    echo -e "\033[36m> Xcode installation confirmed\033[0m"
fi

# Check if the Xcode path is correct
if [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
    echo -e "\033[34m>Changing the Xcode path...\033[0m"
    sudo xcode-select -s "/Applications/Xcode.app/Contents/Developer"
    XCODE_VERSION=$(xcodebuild -version | grep '^Xcode\s' | sed -E 's/^Xcode[[:space:]]+([0-9\.]+)/\1/')
    ACCEPTED_LICENSE_VERSION=$(defaults read /Library/Preferences/com.apple.dt.Xcode 2> /dev/null | grep IDEXcodeVersionForAgreedToGMLicense | cut -d '"' -f 2)
    # Check if the Xcode license has been accepted
    if [ "$XCODE_VERSION" != "$ACCEPTED_LICENSE_VERSION" ]; then
        echo -e "\033[33mWARNING: Xcode license needs to be accepted. Please follow the prompts to accept the license.\033[0m"
        sudo xcodebuild -license
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
            echo -e "\033[31mError: Failed to accept Xcode license. Please try again.\033[0m"
            exit 1
        fi
    fi
fi

# Check Brew installation
which brew > /dev/null
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo -e "\033[36mBrew installation not found! Installing brew... (it could take some time.. wait!\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # shellcheck disable=SC2143
    if [[ $(brew config | grep "Rosetta 2: false") && $(brew --prefix) == "/opt/homebrew" ]]; then
        echo -e "\033[36m> Brew installation confirmed (/opt/homebrew, Rosseta 2: false)\033[0m"
    else
        echo -e "\033[33m> Incorrect Brew configuration detected at /usr/local. This seems to be a Rosetta 2 emulation.\033[0m"
        echo -e "\033[33m> Do you want to remove it and reinstall the native arm64 Brew? (y/n)\033[0m"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo -e "\033[36mRemoving the Rosetta 2 emulated Brew at /usr/local...\033[0m"
            curl -fsSLO https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh
            /bin/bash uninstall.sh --path /usr/local
            echo -e "\033[36mReinstalling the native arm64 Brew...(it could take some time.. wait!)\033[0m"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo -e "\033[31m> Aborting. Please manually correct your Brew configuration.\033[0m"
            exit 1
        fi
    fi
fi

# Check if Installation dir already exists and warn user
echo -e "\033[34m> Check Installation Directory\033[0m"
if [ -d "$HOME/$ROS_INSTALL_ROOT" ]; then
    echo -e "\033[33mWARNING: The directory $ROS_INSTALL_ROOT already exists at user home($HOME)."
    echo -e "\033[33m         This script will overwrite(remove everything inside) the existing directory.\033[0m"
    read -p "Do you want to continue? [y/n/r] (y to overwrite, n to cancel, r to change install directory name): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[33mOverwriting existing directory...\033[0m"
        # shellcheck disable=SC2115
        rm -rf "$HOME/$ROS_INSTALL_ROOT"
    elif [[ $REPLY =~ ^[Rr]$ ]]; then
        # shellcheck disable=SC2162
        read -p "Enter a new directory name (which will be generated at home): " ROS_INSTALL_ROOT
        if [ -d "$HOME/$ROS_INSTALL_ROOT" ]; then
            echo -e "\033[31mError: $HOME/$ROS_INSTALL_ROOT already exists. Please choose a different directory.\033[0m"
            exit 1
        fi
    else
        echo -e "\033[31mInstallation aborted.\033[0m"
        exit 1
    fi
fi

# Generate Directory
echo -e "\033[36m> Creating directory $HOME/$ROS_INSTALL_ROOT...\033[0m"
mkdir -p "$HOME/$ROS_INSTALL_ROOT"/src
chown -R "$USER": "$HOME/$ROS_INSTALL_ROOT"

# Move to working directory
pushd "$HOME/$ROS_INSTALL_ROOT" || { 
    echo -e "\033[31mError: Failed to change to directory $HOME/$ROS_INSTALL_ROOT. \
    Please check if the directory exists and you have the necessary permissions.\033[0m"
    exit 1
}

# ------------------------------------------------------------------------------
# Install Dendencies
echo -e "\033[34m### [2/5] Installing Dependencies with Brew (Arm64) and PIP (Python3.11)\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
# Installing ros2 dependencies with brew
echo -e "\033[36m> Installing ROS2 dependencies with Brew...\033[0m"
brew install asio assimp bison bullet cmake console_bridge cppcheck \
  cunit eigen freetype graphviz opencv openssl orocos-kdl pcre poco \
  pyqt5 python@3.11 qt@5 sip spdlog tinyxml tinyxml2

# Remove unnecessary packages
echo -e "\033[36m> Removing unnecessary packages...(ones that causes error, python@3.12, qt6)\033[0m"
if brew list --formula | grep -q "python@3.12"; then
    echo -e "\033[31mWARNING: Python@3.12 installation is found. Currently this does not work with ros2 jazzy. Do you want to remove it? (y/n)\033[0m"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "\033[36m> Removing python@3.12 (with ignore-dependencies)...\033[0m"
        brew uninstall --ignore-dependencies python@3.12
    else
        echo -e "\033[31m> Aborting. Please manually correct your Python configuration.\033[0m"
        exit 1
    fi
fi
if brew list --formula | grep -q "qt6"; then
    echo -e "\033[31mWARNING: qt6 installation is found. Currently this does not work with ros2 jazzy. Do you want to remove it? (y/n)\033[0m"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "\033[36m> Removing qt6 (with ignore-dependencies)...\033[0m"
        brew uninstall --ignore-dependencies qt6
    else
        echo -e "\033[31m> Aborting. Please manually correct your Python configuration.\033[0m"
        exit 1
    fi
fi

# Set Environment Variables of Brew packages
echo -e "\033[36m> Setting Environment Variables of Brew packages...(OPENSSL_ROOT_DIR, CMAKE_PREFIX_PATH, PATH)\033[0m"
# shellcheck disable=SC2155
export OPENSSL_ROOT_DIR=$(brew --prefix openssl@3)
PATH_TO_QT5="/opt/homebrew/opt/qt@5"
# shellcheck disable=SC2155
export CMAKE_PREFIX_PATH=${PATH_TO_QT5}:$(brew --prefix qt@5)/lib:/opt/homebrew/opt:$(brew --prefix)/lib
export PATH=$PATH:${PATH_TO_QT5}/bin
# Disable notification error on mac
export COLCON_EXTENSION_BLOCKLIST=colcon_core.event_handler.desktop_notification

# Confirm message
echo -e "\033[36m> Packages installation with Brew completed.\033[0m"

# Check Python3.11 installation
if ! python3.11 --version > /dev/null 2>&1; then
    echo -e "\033[31mError: Python3.11 installation failed. Please check the installation.\033[0m"
    exit 1
fi
# Generate Python3.11 virtual environment
echo -e "\033[36m> Generating Python3.11 virtual environment at $HOME/$ROS_INSTALL_ROOT/install_venv\033[0m"
python3.11 -m venv install_venv

# Activate Python3.11 virtual environment
# shellcheck disable=SC1091
source install_venv/bin/activate

# Install Python3.11 dependencies with pip
echo -e "\033[36m> Installing Python3.11 dependencies with PIP in virtual environment...\033[0m"
python3 -m pip install --upgrade pip
python3 -m pip install -U \
  argcomplete catkin_pkg colcon-common-extensions coverage \
  cryptography empy flake8 flake8-blind-except==0.1.1 flake8-builtins \
  flake8-class-newline flake8-comprehensions flake8-deprecated \
  flake8-docstrings flake8-import-order flake8-quotes \
  importlib-metadata jsonschema lark==1.1.1 lxml matplotlib mock mypy==0.931 netifaces \
  nose pep8 psutil pydocstyle pydot pyparsing==2.4.7 \
  pytest-mock rosdep rosdistro setuptools==59.6.0 vcstool
python3 -m pip install \
  --config-settings="--global-option=build_ext" \
  --config-settings="--global-option=-I/opt/homebrew/opt/graphviz/include/" \
  --config-settings="--global-option=-L/opt/homebrew/opt/graphviz/lib/" \
    pygraphviz


