#!/bin/bash
################################################################################
########### ROS2 Jazzy Installation Script for MacOS (Apple Silicon) ###########
################################################################################
# Author: Choi Woen-Sug (GithubID: woensug-choi)
# First Created: 2024.6.15
################################################################################
# References: (None of below worked for me, so I made this script)
# - https://github.com/pfavr2/install_ros2_rolling_on_mac_m1
# - https://chenbrian.ca/posts/ros2_m1/
# - https://github.com/TakanoTaiga/ros2_m1_native
# - https://docs.ros.org/en/jazzy/Installation/Alternatives/macOS-Development-Setup.html
#
# To Run this script, you need to have the following installed (the script will check):
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
JAZZY_RELEASE_TAG="release-jazzy-20240523"

# Print welcome message
echo -e "\033[32m\n"
echo "---------------------------------------------------------"
echo "| 👋 Welcome to the MacOS installation of ROS2 Jazzy 🚧 |"
echo "| 🍎 (Apple Silicon) + 🤖 = 🚀❤️       by Choi Woen-Sug  |"
echo "---------------------------------------------------------"
echo -e Target Installation Directory : "\033[94m$HOME/$ROS_INSTALL_ROOT\033[0m"
echo -e Target Jazzy Release Version  : "\033[94m$JAZZY_RELEASE_TAG\033[0m"
echo -e "\033[0m"
echo -e "Source code at: "
echo -e "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/install.sh"
# ------------------------------------------------------------------------------
# Check System
echo -e "\033[34m\n\n### [1/6] Checking System Requirements\033[0m"
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

# Check Brew shellenv configuration
# shellcheck disable=SC2016
if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check if Installation dir already exists and warn user
echo -e "\033[34m> Check Installation Directory\033[0m"
if [ -d "$HOME/$ROS_INSTALL_ROOT" ]; then
    echo -e "\033[33mWARNING: The directory $ROS_INSTALL_ROOT already exists at user home($HOME)."
    echo -e "\033[33m         This script will merge and overwrite the existing directory.\033[0m"
    read -p "Do you want to continue? [y/n/r/c] (y to merge, n to cancel, r to change install directory name, c for force reinstall): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[33mMerging and overwriting existing directory...\033[0m"
    elif [[ $REPLY =~ ^[Rr]$ ]]; then
        # shellcheck disable=SC2162
        read -p "Enter a new directory name (which will be generated at home): " ROS_INSTALL_ROOT
        if [ -d "$HOME/$ROS_INSTALL_ROOT" ]; then
            echo -e "\033[31mError: $HOME/$ROS_INSTALL_ROOT already exists. Please choose a different directory.\033[0m"
            exit 1
        fi
    elif [[ $REPLY =~ ^[Cc]$ ]]; then
        echo -e "\033[33mPerforming clean reinstall...\033[0m"
        # shellcheck disable=SC2115
        rm -rf "$HOME/$ROS_INSTALL_ROOT"
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
echo -e "\033[34m\n\n### [2/6] Installing Dependencies with Brew and PIP\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
# Installing ros2 dependencies with brew
echo -e "\033[36m> Installing ROS2 dependencies with Brew...\033[0m"
brew install asio assimp bison bullet cmake console_bridge cppcheck \
  cunit eigen freetype graphviz opencv openssl orocos-kdl pcre poco \
  pyqt@5 python@3.11 qt@5 sip spdlog tinyxml tinyxml2

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

# Confirm message
echo -e "\033[36m> Packages installation with PIP completed.\033[0m"

# ------------------------------------------------------------------------------
# Downloading ROS2 Jazzy Source Code
echo -e "\033[34m\n\n### [3/6] Downloading ROS2 Jazzy Source Code\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
# Get ROS2 Jazzy Source Code (Jazzy-Release Version of $JAZZY_RELEASE_TAG)
echo -e "\033[36m> Getting ROS2 Jazzy Source Code (Jazzy-Release tag of $JAZZY_RELEASE_TAG)...\033[0m"
vcs import --input https://raw.githubusercontent.com/ros2/ros2/$JAZZY_RELEASE_TAG/ros2.repos src
# Run partially to generate compile output structure
echo -e "\033[36m> Running colcon build packages-up-to cyclonedds\033[0m"
echo -e "\033[36m  Only for generating compile output structure, not for actual building\033[0m"
colcon build --symlink-install  --cmake-args -DBUILD_TESTING=OFF -Wno-dev --packages-skip-by-dep python_qt_binding --packages-up-to cyclonedds

# ------------------------------------------------------------------------------
# Patch files for Mac OS X Installation
echo -e "\033[34m\n\n### [4/6] Patching files for Mac OS X (Apple Silicon) Installation\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
# Apply patch for cyclonedds
echo -e "\033[36m> Applying patch for cyclonedds...\033[0m"
ln -s "../../iceoryx_posh/lib/libiceoryx_posh.dylib" install/iceoryx_binding_c/lib/libiceoryx_posh.dylib
ln -s "../../iceoryx_hoofs/lib/libiceoryx_hoofs.dylib" install/iceoryx_binding_c/lib/libiceoryx_hoofs.dylib
ln -s "../../iceoryx_hoofs/lib/libiceoryx_platform.dylib" install/iceoryx_binding_c/lib/libiceoryx_platform.dylib

# Apply patch for setuptools installation
echo -e "\033[36m> Applying patch for setuptools installation...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/python_setuptools_install.patch \
  | patch -N
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/python_setuptools_easy_install.patch \
  | patch -N

# Patch for orocos-kdl
echo -e "\033[36m> Applying patch for orocos-kdl (to use brew installed package)...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/geometry2_tf2_eigen_kdl.patch \
  | patch -N
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/ros_visualization_interactive_markers.patch \
  | patch -N
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/kdl_parser.patch \
  | patch -N

# Patch for rviz_ogre_vendor
echo -e "\033[36m> Applying patch for rviz_ogre_vendor...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rviz_default_plugins.patch \
  | patch -N
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rviz_ogre_vendor.patch \
  | patch -N
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/0001-pragma.patch \
  | patch -N

# Patch for rosbag2_transport
echo -e "\033[36m> Applying patch for rosbag2_transport...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rosbag2_transport.patch \
  | patch -N

# Fix brew linking of qt5
echo -e "\033[36m> Fixing brew linking of qt5...\033[0m"
brew unlink qt && brew link qt@5

# Revert python_orocos_kdl_vendor back to 0.4.1
echo -e "\033[36m> Reverting python_orocos_kdl_vendor back to 0.4.1...\033[0m"
( cd ./src/ros2/orocos_kdl_vendor/python_orocos_kdl_vendor || exit; git checkout 0.4.1 )

# ------------------------------------------------------------------------------
# Building ROS2 Jazzy
echo -e "\033[34m\n\n### [5/6] Building ROS2 Jazzy (This may take about 15 minutes)\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo
# ------------------------------------------------------------------------------
colcon build \
 --symlink-install \
 --packages-skip-by-dep python_qt_binding \
 --cmake-args \
   --no-warn-unused-cli \
   -DBUILD_TESTING=OFF \
   -DINSTALL_EXAMPLES=ON \
   -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
   -DCMAKE_OSX_ARCHITECTURES="arm64" \
   -DPython3_EXECUTABLE="$(pwd)/../ros2_venv/bin/python3"

# ------------------------------------------------------------------------------
# Post Installation Configuration
echo -e "\033[34m\n\n### [6/6] Post Installation Configuration\033[0m"
printf '\033[34m%.0s=\033[0m' {1..56} && echo

