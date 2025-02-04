#!/bin/bash
################################################################################
######### ROS2 Jazzy Gazebo Harmonic Install for MacOS (Apple Silicon) #########
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
JAZZY_RELEASE_TAG_DEFAULT="release-jazzy-20241223" # you may change with option -t
ROS_INSTALL_ROOT_DEFAULT="ros2_jazzy" # you may change with option -d
VIRTUAL_ENV_ROOT_DEFAULT=".ros2_venv" # you may change with option -v
# ------------------------------------------------------------------------------
# Installation Configuration and Options
# ------------------------------------------------------------------------------

# Usage function
usage() {
    echo "Usage: [-d ROS_INSTALL_ROOT] [-t JAZZY_RELEASE_TAG] [-v VIRTUAL_ENV_ROOT] [-h] [-u to uninstall]"
    echo "  -t    Set the Jazzy release tag (default: $JAZZY_RELEASE_TAG_DEFAULT)"
    echo "        (e.g., release-jazzy-20240523, you may find tag at https://github.com/ros2/ros2/tags"
    echo "  -d    Set the ROS installation root directory (default: $ROS_INSTALL_ROOT_DEFAULT)"
    echo "  -v    Set the Python Virtual Environment directory (default: $VIRTUAL_ENV_ROOT_DEFAULT)"
    echo "  -u    To uninstall"
    exit 1
}

# Parse command-line arguments
while getopts "d:t:h:v:au" opt; do
    case ${opt} in
        d)
            ROS_INSTALL_ROOT=$OPTARG
            ;;
        v)
            VIRTUAL_ENV_ROOT=$OPTARG
            ;;
        t)
            JAZZY_RELEASE_TAG=$OPTARG
            ;;
        h)
            usage
            ;;
        a)
            GITHUB_ACTIONS=true
            ;;
        u)
            # Check flag variable to uninstall later
            UNINSTALL_FLAG=1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Set default values if variables are not set
JAZZY_RELEASE_TAG=${JAZZY_RELEASE_TAG:-$JAZZY_RELEASE_TAG_DEFAULT}
ROS_INSTALL_ROOT=${ROS_INSTALL_ROOT:-$ROS_INSTALL_ROOT_DEFAULT}
VIRTUAL_ENV_ROOT=${VIRTUAL_ENV_ROOT:-$VIRTUAL_ENV_ROOT_DEFAULT}

# If uninstall
if [ -n "$UNINSTALL_FLAG" ]; then
    echo -e "\033[31mUninstall installation request found!\033[0m"
    if [ -f "$HOME/.ros2_jazzy_install_config" ]; then
        # shellcheck disable=SC1091
        source "$HOME/.ros2_jazzy_install_config"
        echo "⚠️  The following directories will be removed:"
        [ -n "$ROS_INSTALL_ROOT" ] && [ -d "$HOME/$ROS_INSTALL_ROOT" ] && echo "  - $HOME/$ROS_INSTALL_ROOT"
        [ -n "$VIRTUAL_ENV_ROOT" ] && [ -d "$HOME/$VIRTUAL_ENV_ROOT" ] && echo "  - $HOME/$VIRTUAL_ENV_ROOT"
        [ -n "$GZ_INSTALL_ROOT" ] && [ -d "$HOME/$GZ_INSTALL_ROOT" ] && echo "  - $HOME/$GZ_INSTALL_ROOT"
        read -p $'\033[31m🚨 Are you sure you want to continue? (y/n) \033[0m' -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            read -p $'\033[31m🚨 Are you absolutely sure? There is NO going back. (y/n) \033[0m' -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                # shellcheck disable=SC2115
                [ -n "$ROS_INSTALL_ROOT" ] && [ -d "$HOME/$ROS_INSTALL_ROOT" ] && rm -rf "$HOME/$ROS_INSTALL_ROOT"
                # shellcheck disable=SC2115
                [ -n "$VIRTUAL_ENV_ROOT" ] && [ -d "$HOME/$VIRTUAL_ENV_ROOT" ] && rm -rf "$HOME/$VIRTUAL_ENV_ROOT"
                # shellcheck disable=SC2115
                [ -n "$GZ_INSTALL_ROOT" ] && [ -d "$HOME/$GZ_INSTALL_ROOT" ] && rm -rf "$HOME/$GZ_INSTALL_ROOT"
                rm -f "$HOME/.ros2_jazzy_install_config"
                # Confirm message
                echo -e "\033[32m\nUninstallation completed successfully.\n\033[0m"
            fi
        fi
    else
        echo -e "\033[31m❌ Error: Configuration file not found at $HOME/.ros2_jazzy_install_config\033[0m"
        echo -e "it seems that the installation is not found. Please check the installation directory.\n"
        exit 1
    fi
    exit 0
fi

# Get Current Version hash
LATEST_COMMIT_HASH=$(curl -s "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/commits/main" | \
        grep -o 'commit/[0-9a-f]*' | \
        head -n 1 | \
        cut -d'/' -f2 | \
        cut -c1-7)
LATEST_COMMIT_DATE=$(curl -s "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/commits/main" | \
        grep -o 'title":"[A-Za-z]\{3\} [0-9]\{1,2\}, [0-9]\{4\}' | head -n 1 | sed 's/title":"//')


# ------------------------------------------------------------------------------
# Initiation
# ------------------------------------------------------------------------------
# Print welcome message
echo -e "\nRunning Installation script for ROS-Gazebo framework. ROS2 Jazzy first.\033[32m"
echo "▣-------------------------------------------------------------------------▣"
echo "|  ______  ______  ______         __  ______  ______  ______  __  __      |"
echo "| /\  == \/\  __ \/\  ___\       /\ \/\  __ \/\___  \/\___  \/\ \_\ \     |"
echo "| \ \  __<\ \ \/\ \ \___  \     _\_\ \ \  __ \/_/  /_\/_/  /_\ \____ \    |"
echo "|  \ \_\ \_\ \_____\/\_____\   /\_____\ \_\ \_\/\_____\/\_____\/\_____\   |"
echo "|   \/_/ /_/\/_____/\/_____/   \/_____/\/_/\/_/\/_____/\/_____/\/_____/   |"
echo "|  ______  ______ ______ __      ______       __    __  ______  ______    |"
echo "| /\  __ \/\  == /\  == /\ \    /\  ___\     /\ \-./\ \/\  __ \/\  ___\   |"
echo "| \ \  __ \ \  _-\ \  _-\ \ \___\ \  __\     \ \ \-./\ \ \  __ \ \ \____  |"
echo "|  \ \_\ \_\ \_\  \ \_\  \ \_____\ \_____\    \ \_\ \ \_\ \_\ \_\ \_____\ |"
echo "|   \/_/\/_/\/_/   \/_/   \/_____/\/_____/     \/_/  \/_/\/_/\/_/\/_____/ |"
echo "|                                                                         |"
echo "| 👋 Welcome to the Instllation of ROS2 Jazzy on MacOS(Apple Silicon)  🚧 |"
echo "| 🍎 (Apple Silicon)+🤖 = 🚀❤️🤩🎉🥳                                       |"
echo "|                                                                         |"
echo "|                                   by Choi Woen-Sug(Github:woensug-choi) |"
echo "▣-------------------------------------------------------------------------▣"
echo -e "| Current Installer Version Hash : \033[94m$LATEST_COMMIT_DATE ($LATEST_COMMIT_HASH)\033[0m   \033[32m"
echo -e "| Target Jazzy Release Version   :" "\033[94m$JAZZY_RELEASE_TAG\033[0m"
echo -e "\033[32m|\033[0m Target Installation Directory  :" "\033[94m$HOME/$ROS_INSTALL_ROOT\033[0m"
echo -e "\033[32m|\033[0m Virtual Environment Directory  :" "\033[94m$HOME/$VIRTUAL_ENV_ROOT\033[0m"
echo -e "\033[32m▣-------------------------------------------------------------------------▣\033[0m"
echo -e To change targets use options "-t (tag), -d (install dir), -v (virtual dir)"
echo -e For descriptions, and more options, use -h at the end of oneliner
echo -e "e.g. \033[33m/bin/bash -c '\$(curl -fsSL https://raw. ...install.sh)\"\033[0m" "\033[94m-- -h\033[0m"
echo -e "\033[0m"
echo -e "Source code at: "
echo -e "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/install.sh\n"
echo -e "\033[33m⚠️  WARNING: The FAN WILL BURST out and make macbook to take off. Be warned!\033[0m"
echo -e "\033[33m            It will take upto 30 minutes depending on hardware and network.\033[0m"
echo -e "\033[33m            To terminate at any process, press Ctrl+C.\033[0m"

# Trap SIGINT (Ctrl+C) and exit cleanly
trap 'echo -e "\033[31m\nInstallation aborted.\033[0m"; exit' SIGINT

# Check if the script is running in a GitHub Actions workflow
if [[ -z "$GITHUB_ACTIONS" ]]; then
    # Prompt the user and wait for a response with a timeout of 20 seconds
    echo -e '\033[96m\n💡 The installation will continue automatically in 20 seconds.\033[0m'
    read -p $'\033[96m   Do you want to proceed now? [y/n]: \033[0m' -n 1 -r -t 20 response
    echo # Move to a new line after the user input

    # Default to 'y' if no response is given within the timeout
    response=${response:-y}
else
    # Automatically set the response to 'y' in a GitHub Actions workflow
    response='y'
fi

# Check the response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\033[31m\nInstallation aborted.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# Check System
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [1/6] Checking System Requirements\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
echo -e "Checking System Requirements..."
# Check XCode installation"
if [ ! -e "/Applications/Xcode.app/Contents/Developer" ]; then
    echo -e "\033[31m❌ Error: Xcode is not installed. Please install Xcode through the App Store."
    echo -e "\033[31m          You can download it from: https://apps.apple.com/app/xcode/id497799835\033[0m"
    exit 1
else
    echo -e "\033[36m> Xcode installation confirmed\033[0m"
fi

# Check if the Xcode path is correct
if [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
    sudo xcode-select -s "/Applications/Xcode.app/Contents/Developer"
    XCODE_VERSION=$(xcodebuild -version | grep '^Xcode\s' | sed -E 's/^Xcode[[:space:]]+([0-9\.]+)/\1/')
    ACCEPTED_LICENSE_VERSION=$(defaults read /Library/Preferences/com.apple.dt.Xcode 2> /dev/null | grep IDEXcodeVersionForAgreedToGMLicense | cut -d '"' -f 2)
    sudo xcodebuild -license accept
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
        echo -e "\033[33m> 💡 Do you want to remove it and reinstall the native arm64 Brew? (y/n)\033[0m"
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
    echo -e "\033[33m⚠️  WARNING: The directory $ROS_INSTALL_ROOT already exists at home ($HOME)."
    echo -e "\033[33m         This script will merge and overwrite the existing directory.\033[0m"
    echo -e "\033[96mDo you want to continue? [y/n/r/c]\033[0m"
    read -p "(y) Merge (n) Cancel (r) Change directory, (c) Clean re-install: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[33mMerging and overwriting existing directory...\033[0m"
    elif [[ $REPLY =~ ^[Rr]$ ]]; then
        # shellcheck disable=SC2162
        read -p "Enter a new directory name (which will be generated at home): " ROS_INSTALL_ROOT
        if [ -d "$HOME/$ROS_INSTALL_ROOT" ]; then
            echo -e "\033[31m❌ Error: $HOME/$ROS_INSTALL_ROOT already exists. Please choose a different directory.\033[0m"
            exit 1
        fi
    elif [[ $REPLY =~ ^[Cc]$ ]]; then
        echo -e "\033[33mPerforming clean reinstall...\033[0m"
        # shellcheck disable=SC2115
        rm -rf "$HOME/$ROS_INSTALL_ROOT"
        if [ -d "$HOME/$VIRTUAL_ENV_ROOT" ]; then
            # shellcheck disable=SC2115
            rm -rf "$HOME/$VIRTUAL_ENV_ROOT"
        fi
    else
        echo -e "\033[31mInstallation aborted.\033[0m"
        exit 1
    fi
fi

# Generate Directory
echo -e "\033[36m> Creating directory $HOME/$ROS_INSTALL_ROOT...\033[0m"
mkdir -p "$HOME/$ROS_INSTALL_ROOT"/src
chown -R "$USER": "$HOME/$ROS_INSTALL_ROOT" > /dev/null 2>&1

# Move to working directory
pushd "$HOME/$ROS_INSTALL_ROOT" || { 
    echo -e "\033[31m❌ Error: Failed to change to directory $HOME/$ROS_INSTALL_ROOT. \
    Please check if the directory exists and you have the necessary permissions.\033[0m"
    exit 1
}

# ------------------------------------------------------------------------------
# Install Dendencies
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [2/6] Installing Dependencies with Brew and PIP\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Installing ros2 dependencies with brew
echo -e "\033[36m> Installing ROS2 dependencies with Brew...\033[0m"
brew install asio assimp bison bullet cmake console_bridge cppcheck \
  cunit eigen freetype graphviz opencv openssl orocos-kdl pcre poco \
  pyqt@5 python@3.11 qt@5 sip spdlog tinyxml tinyxml2

# Set Environment Variables of Brew packages
echo -e "\033[36m> Setting Environment Variables of Brew packages...(OPENSSL_ROOT_DIR, CMAKE_PREFIX_PATH, PATH)\033[0m"
# shellcheck disable=SC2155
export OPENSSL_ROOT_DIR=$(brew --prefix openssl@3)
# shellcheck disable=SC2155
export CMAKE_PREFIX_PATH=$(brew --prefix qt@5)/lib:$(brew --prefix qt@5)/lib/cmake:/opt/homebrew/opt:${CMAKE_PREFIX_PATH}
# shellcheck disable=SC2155
export PATH=$PATH:$(brew --prefix qt@5)/bin
# Disable notification error on mac
export COLCON_EXTENSION_BLOCKLIST=colcon_core.event_handler.desktop_notification

# Confirm message
echo -e "\033[36m\n> Packages installation with Brew completed.\033[0m"

# Check Python3.11 installation
if ! python3.11 --version > /dev/null 2>&1; then
    echo -e "\033[31m❌ Error: Python3.11 installation failed. Please check the installation.\033[0m"
    exit 1
fi
# Generate Python3.11 virtual environment
echo -e "\033[36m> Generating Python3.11 virtual environment at $HOME/$VIRTUAL_ENV_ROOT\033[0m"
python3.11 -m venv "$HOME/$VIRTUAL_ENV_ROOT"

# Activate Python3.11 virtual environment
# shellcheck disable=SC1091,SC1090
source "$HOME/$VIRTUAL_ENV_ROOT"/bin/activate

# Install Python3.11 dependencies with pip
echo -e "\033[36m> Installing Python3.11 dependencies with PIP in virtual environment...\033[0m"
python3 -m pip install --upgrade pip
python3 -m pip install -U \
  argcomplete catkin_pkg colcon-common-extensions coverage \
  cryptography empy==3.3.4 flake8 flake8-blind-except==0.1.1 flake8-builtins \
  flake8-class-newline flake8-comprehensions flake8-deprecated \
  flake8-docstrings flake8-import-order flake8-quotes \
  importlib-metadata jsonschema lark==1.1.1 lxml matplotlib mock mypy==0.931 netifaces \
  nose pep8 psutil pydocstyle pydot pyparsing==2.4.7 \
  pytest-mock rosdep rosdistro setuptools==59.6.0 vcstool
python3 -m pip install \
  --config-settings="--global-option=build_ext" \
  --config-settings="--global-option=-I$(brew --prefix graphviz)/include/" \
  --config-settings="--global-option=-L$(brew --prefix graphviz)/lib/" \
    pygraphviz

# Confirm message
echo -e "\033[36m> Packages installation with PIP completed.\033[0m"

# ------------------------------------------------------------------------------
# Downloading ROS2 Jazzy Source Code
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [3/6] Downloading ROS2 Jazzy Source Code\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Reset git directories (git clean -d -f .) if they exist inside src directory
if [ -d "src" ]; then
    echo -e "\033[36m> Resetting git directories inside src...\033[0m"
    find src -name ".git" -type d -execdir bash -c 'if [ -d ".git" ]; then git clean -d -f .; fi' \;
fi

# Get ROS2 Jazzy Source Code (Jazzy-Release Version of $JAZZY_RELEASE_TAG)
echo -e "\033[36m\n> Getting ROS2 Jazzy Source Code (Jazzy-Release tag of $JAZZY_RELEASE_TAG)...\033[0m"
echo -e "As long as the spinner at of the terminal is running, it is downloading the source code."
echo -e "'E' in the progress means that the download has failed (slow connection?), it will try again."
echo -e "If it takes too long, please check your network connection and try again. To cancel, Ctrl+C."
echo -e "\033[33mSTART----------------------------------    DOWNLOADING...  ---------------------------------------------END\033[0m"

# Define maximum number of retries
max_retries=3
# Start loop
for ((i=1;i<=max_retries;i++)); do
    # Try to import the repositories
    if vcs import --force --shallow --retry 0 \
        --input https://raw.githubusercontent.com/ros2/ros2/$JAZZY_RELEASE_TAG/ros2.repos src;
        then
        echo -e "\033[36m\n> ROS2 Jazzy Source Code Import Successful\033[0m"
        break
    else
        echo -e "\033[31m\nROS2 Jazzy Source Code Import failed, retrying ($i/$max_retries)\033[0m"
        echo -e "\033[33mSTART----------------------------------    DOWNLOADING...  ---------------------------------------------END\033[0m"
    fi
    # If we've reached the max number of retries, exit the script
    if [ $i -eq $max_retries ]; then
        echo -e "\033[31m\nROS2 Jazzy Source Code Import failed after $max_retries attempts, terminating script.\033[0m"
        exit 1
    fi
    # Wait before retrying
    sleep 5
done

# Run partially to generate compile output structure
echo -e "\033[36m> Running colcon build packages-up-to cyclonedds\033[0m"
echo -e "\033[36m  Only for generating compile output structure, not for actual building\033[0m"
python3 -m colcon build --symlink-install --cmake-args -DBUILD_TESTING=OFF -Wno-dev \
             -Wno-sign-conversion -Wno-infinite-recursion \
             --packages-skip-by-dep python_qt_binding --packages-up-to cyclonedds \
             --event-handlers console_cohesion+ || true
# Confirm message
echo -e "\033[36m> Don't panic. It's correct that above colcon build to fail.\033[0m"
echo -e "\033[36m> It was for generation build structure to apply patches.\033[0m\n"
echo -e "\033[36m> ROS2 Jazzy Source Code Download and Preparation Completed.\033[0m"

# ------------------------------------------------------------------------------
# Patch files for Mac OS X Installation
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [4/6] Patching files for Mac OS X (Apple Silicon) Installation\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Apply patch for cyclonedds
echo -e "\033[36m> Applying patch for cyclonedds...\033[0m"
if [ -f install/iceoryx_binding_c/lib/libiceoryx_posh.dylib ]; then
    rm install/iceoryx_binding_c/lib/libiceoryx_posh.dylib
fi
ln -s "../../iceoryx_posh/lib/libiceoryx_posh.dylib" install/iceoryx_binding_c/lib/libiceoryx_posh.dylib
if [ -f install/iceoryx_binding_c/lib/libiceoryx_hoofs.dylib ]; then
    rm install/iceoryx_binding_c/lib/libiceoryx_hoofs.dylib
fi
ln -s "../../iceoryx_hoofs/lib/libiceoryx_hoofs.dylib" install/iceoryx_binding_c/lib/libiceoryx_hoofs.dylib
if [ -f install/iceoryx_binding_c/lib/libiceoryx_platform.dylib ]; then
    rm install/iceoryx_binding_c/lib/libiceoryx_platform.dylib
fi
ln -s "../../iceoryx_hoofs/lib/libiceoryx_platform.dylib" install/iceoryx_binding_c/lib/libiceoryx_platform.dylib

# Apply patch for setuptools installation
# echo -e "\033[36m> Applying patch for setuptools installation...\033[0m"
# curl -sSL \
#   https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/python_setuptools_install.patch \
#   | patch -p1 -Ns
# curl -sSL \
#   https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/python_setuptools_easy_install.patch \
#   | patch -p1 -Ns

# Patch for orocos-kdl
echo -e "\033[36m> Applying patch for orocos-kdl (to use brew installed package)...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/geometry2_tf2_eigen_kdl.patch \
  | patch -p1 -Ns
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/ros_visualization_interactive_markers.patch \
  | patch -p1 -Ns
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/kdl_parser.patch \
  | patch -p1 -Ns

# Patch for rviz_ogre_vendor
echo -e "\033[36m> Applying patch for rviz_ogre_vendor...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rviz_default_plugins.patch \
  | patch -p1 -Ns
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rviz_ogre_vendor.patch \
  | patch -p1 -Ns
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/0001-pragma.patch \
  | patch -p1 -Ns

# Patch for rosbag2_transport
echo -e "\033[36m> Applying patch for rosbag2_transport...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/patches/rosbag2_transport.patch \
  | patch -p1 -Ns

# Patch for fastrtps
echo -e "\033[36m> Applying patch for fastrtps of Fast-DDS ...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/version_update/patches/fastrtps.patch \
  | patch -p1 -Ns

# Fix brew linking of qt5
echo -e "\033[36m> Fixing brew linking of qt5...\033[0m"
brew unlink qt && brew link qt@5

# Revert python_orocos_kdl_vendor back to 0.4.1
echo -e "\033[36m> Reverting python_orocos_kdl_vendor back to 0.4.1...\033[0m"
if [ -d "src/ros2/orocos_kdl_vendor" ]; then
    rm -rf src/ros2/orocos_kdl_vendor
    git clone https://github.com/ros2/orocos_kdl_vendor.git src/ros2/orocos_kdl_vendor
    ( cd ./src/ros2/orocos_kdl_vendor/python_orocos_kdl_vendor || exit; git checkout 0.4.1 )
fi

# Remove eclipse-cyclonedds (compile error)
echo -e "\033[36m> Removing eclipse-cyclonedds (compile errors)\033[0m"
if [ -d "src/eclipse-cyclonedds" ]; then
    rm -rf src/eclipse-cyclonedds
fi

# ------------------------------------------------------------------------------
# Building ROS2 Jazzy
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [5/6] Building ROS2 Jazzy (This may take about 15 minutes)\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# if ! colcon build --symlink-install --cmake-args -DBUILD_TESTING=OFF -Wno-dev --packages-skip-by-dep python_qt_binding;
if ! python3.11 -m colcon build  --symlink-install \
    --packages-skip-by-dep python_qt_binding \
    --cmake-args \
    --no-warn-unused-cli \
    -DBUILD_TESTING=OFF \
    -DINSTALL_EXAMPLES=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DPython3_EXECUTABLE=$HOME/$VIRTUAL_ENV_ROOT/bin/python3 \
    -Wno-dev --event-handlers console_cohesion+;
    then
    echo -e "\033[31m❌ Error: Build failed, aborting script.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# Post Installation Configuration
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [6/6] Post Installation Configuration\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# save JAZZY_RELEASE_TAG, VIRTUAL_ENV_ROOT, VIRTUAL_ENV_ROOT in a file
if [ -f "$HOME/.ros2_jazzy_install_config" ]; then
    rm "$HOME/.ros2_jazzy_install_config"
fi
echo "JAZZY_RELEASE_TAG=$JAZZY_RELEASE_TAG" > "$HOME/.ros2_jazzy_install_config"
echo "VIRTUAL_ENV_ROOT=$VIRTUAL_ENV_ROOT" >> "$HOME/.ros2_jazzy_install_config"
echo "ROS_INSTALL_ROOT=$ROS_INSTALL_ROOT" >> "$HOME/.ros2_jazzy_install_config"

# Download sentenv.sh
if [ -f setenv.sh ]; then
    rm setenv.sh
fi
curl -s -O https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/setenv.sh

# Replace string inside sentenv.sh
sed -i '' "s|ROS_INSTALL_ROOT|$ROS_INSTALL_ROOT|g" setenv.sh
sed -i '' "s|VIRTUAL_ENV_ROOT|$VIRTUAL_ENV_ROOT|g" setenv.sh

# Rename sentenv.sh to activate_ros
if [ -f activate_ros ]; then
    rm activate_ros
fi
mv setenv.sh activate_ros

# Print post messages
printf '\033[32m%.0s=\033[0m' {1..75} && echo
echo -e "\033[32m🎉 Done. Hurray! 🍎 (Apple Silicon) + 🤖 = 🚀❤️🤩🎉🥳 \033[0m"
echo
echo "To activate the new ROS2 distribution run the following command:"
echo -e "\033[32msource $HOME/$ROS_INSTALL_ROOT/activate_ros\033[0m"
echo -e "\nThen, try '\033[32mros2\033[0m' or '\033[32mrviz2\033[0m' in the terminal to start ROS2 Jazzy."
printf '\033[32m%.0s=\033[0m' {1..75} && echo
echo "To make alias for fast start, run the following command to add to ~/.zprofile:"
echo -e "\033[34mecho 'alias ros=\"source $HOME/$ROS_INSTALL_ROOT/activate_ros\"' >> ~/.zprofile && source ~/.zprofile\033[0m"
echo
echo -e "Then, you can start ROS2 Jazzy by typing '\033[34mros\033[0m' in the terminal (new terminal)."
echo -e "You may change the alias name to your preference in above alias command."
echo
echo "To deactivate this workspace, run:"
echo -e "\033[33mdeactivate\033[0m"

# ------------------------------------------------------------------------------
# Gazebo Installation 
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [Optional] Gazebo Harmonic Installation\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Ask if user wants to install Gazebo Harmonic too
echo -e "\n\033[32mGazebo Harmonic is simulator that is LTS pair with ROS2 Jazzy\033[0m"

# Trap SIGINT (Ctrl+C) and exit cleanly
trap 'echo -e "\033[31m\nInstallation aborted.\033[0m"; exit' SIGINT

# Check if the script is running in a GitHub Actions workflow
if [[ -z "$GITHUB_ACTIONS" ]]; then
    # Prompt the user and wait for a response with a timeout of 20 seconds
    echo -e '\033[96m\n💡 The installation will continue automatically in 20 seconds unless you respond. \033[0m'
    read -p $'\033[96m   Do you want to proceed now? [y/n]: \033[0m' -n 1 -r -t 20 response
    echo # Move to a new line after the user input

    # Default to 'y' if no response is given within the timeout
    response=${response:-y}
else
    # Automatically set the response to 'y' in a GitHub Actions workflow
    response='y'
fi

# Check the response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\033[31m\nInstallation aborted.\033[0m"
    exit 1
fi

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\033[36m> Installing Gazebo Harmonic...\033[0m"
    # shellcheck disable=SC2086
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/gz_install.sh)" \
    #     -- -r $ROS_INSTALL_ROOT -v $VIRTUAL_ENV_ROOT
    brew tap osrf/simulation
    ulimit -n 4096
    brew install gz-harmonic
fi

popd || exit
