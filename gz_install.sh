#!/bin/bash
################################################################################
######## Gazebo Harmonic Installation Script for MacOS (Apple Silicon) #########
################################################################################
# Author: Choi Woen-Sug (GithubID: woensug-choi)
# First Created: 2024.6.15
################################################################################
# References: 
# - https://gazebosim.org/docs/harmonic/install_osx_src
# Assumes that ROS2 Jazzy is already installed.
#
# Also, need to make this script executable
# chmod +x gz_install.sh
################################################################################
ROS_INSTALL_ROOT_DEFAULT="ros2_jazzy" # you may change with option -r
GZ_INSTALL_ROOT_DEFAULT="gz_harmonic" # you may change with option -d
VIRTUAL_ENV_ROOT_DEFAULT=".ros2_venv" # you may change with option -v
# ------------------------------------------------------------------------------
# Installation Configuration and Options
# ------------------------------------------------------------------------------

# Usage function
usage() {
    echo "Usage: [-r ROS_INSTALL_ROOT_DEFAULT] [-d GZ_INSTALL_ROOT_DEFAULT] [-v VIRTUAL_ENV_ROOT_DEFAULT] [-h]"
    echo "  -r    Set the ROS installation root directory (default: $ROS_INSTALL_ROOT_DEFAULT)"
    echo "  -d    Set the Gazebo installation root directory (default: $GZ_INSTALL_ROOT_DEFAULT)"
    echo "  -v    Set the Python Virtual Environment directory (default: $VIRTUAL_ENV_ROOT_DEFAULT)"
    exit 1
}

# Parse command-line arguments
while getopts "d:r:h:v:" opt; do
    case ${opt} in
        d)
            GZ_INSTALL_ROOT=$OPTARG
            ;;
        r)
            ROS_INSTALL_ROOT=$OPTARG
            ;;
        v)
            VIRTUAL_ENV_ROOT=$OPTARG
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Set default values if variables are not set
ROS_INSTALL_ROOT=${ROS_INSTALL_ROOT:-$ROS_INSTALL_ROOT_DEFAULT}
GZ_INSTALL_ROOT=${GZ_INSTALL_ROOT:-$GZ_INSTALL_ROOT_DEFAULT}
VIRTUAL_ENV_ROOT=${VIRTUAL_ENV_ROOT:-$VIRTUAL_ENV_ROOT_DEFAULT}

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
echo -e "\033[32m"
echo "▣-------------------------------------------------------------------------▣"
echo "|  ______  ______  ______  ______  ______  ______                         |"
echo "| /\  ___\/\  __ \/\___  \/\  ___\/\  == \/\  __ \                        |"
echo "| \ \ \__ \ \  __ \/_/  /_\ \  __\\ \  __< \ \ \/\ \                       |"
echo "|  \ \_____\ \_\ \_\/\_____\ \_____\ \_____\ \_____\                      |"
echo "|   \/_____/\/_/\/_/\/_____/\/_____/\/_____/\/_____/                      |"
echo "|   __  __  ______  ______  __    __  ______  __   __  __  ______         |"
echo "|  /\ \_\ \/\  __ \/\  == \/\ \"-./  \/\  __ \/\ \"-.\ \/\ \/\  ___\        |"
echo "|  \ \  __ \ \  __ \ \  __<\ \ \-./\ \ \ \/\ \ \ \-.\ \ \ \ \ \____       |"
echo "|   \ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \ \_\ \_____\ \_\\\"\_ \ \_\ \_____\      |"
echo "|    \/_/\/_/\/_/\/_/\/_/ /_/\/_/  \/_/\/_____/\/_/ \/_/\/_/\/_____/      |"
echo "|                                                                         |"
echo "| 👋 Welcome to the Instllation of Gazebo Harmonic on MacOS            🚧 |"
echo "| 🍎 (Apple Silicon)+🤖 = 🚀❤️🤩🎉🥳                                       |"
echo "|                                                                         |"
echo "|  First created at 2024.6.15       by Choi Woen-Sug(Github:woensug-choi) |"
echo "▣-------------------------------------------------------------------------▣"
echo -e "| Current Installer Version Hash : \033[94m$LATEST_COMMIT_DATE($LATEST_COMMIT_HASH)\033[0m   \033[32m"
echo -e "| Target Installation Directory  :" "\033[94m$HOME/$GZ_INSTALL_ROOT\033[0m"
echo -e "\033[32m|\033[0m Virtual Environment Directory  :" "\033[94m$HOME/$VIRTUAL_ENV_ROOT\033[0m"
echo -e "\033[32m▣-------------------------------------------------------------------------▣\033[0m"
echo -e "Source code at: "
echo -e "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/gz_install.sh\n"
echo -e "\033[33m⚠️  WARNING: The FAN WILL BURST out and make macbook to take off. Be warned!\033[0m"
echo -e "\033[33m         To terminate at any process, press Ctrl+C.\033[0m"
# ------------------------------------------------------------------------------
# Check System
printf '\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [1/6] Checking System Requirements\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Check if Installation dir already exists and warn user
echo -e "\033[34m> Check Installation Directory\033[0m"
if [ -d "$HOME/$GZ_INSTALL_ROOT" ]; then
    echo -e "\033[33m⚠️  WARNING: The directory $GZ_INSTALL_ROOT already exists at home ($HOME)."
    echo -e "\033[33m         This script will merge and overwrite the existing directory.\033[0m"
    echo -e "\033[33mDo you want to continue? [y/n/r/c]\033[0m"
    read -p "(y) Merge (n) Cancel (r) Change directory, (c) Clean re-install: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[33mMerging and overwriting existing directory...\033[0m"
    elif [[ $REPLY =~ ^[Rr]$ ]]; then
        # shellcheck disable=SC2162
        read -p "Enter a new directory name (which will be generated at home): " GZ_INSTALL_ROOT
        if [ -d "$HOME/$GZ_INSTALL_ROOT" ]; then
            echo -e "\033[31m❌ Error: $HOME/$GZ_INSTALL_ROOT already exists. Please choose a different directory.\033[0m"
            exit 1
        fi
    elif [[ $REPLY =~ ^[Cc]$ ]]; then
        echo -e "\033[33mPerforming clean reinstall...\033[0m"
        # shellcheck disable=SC2115
        rm -rf "$HOME/$GZ_INSTALL_ROOT"
    else
        echo -e "\033[31mInstallation aborted.\033[0m"
        exit 1
    fi
fi

# Generate Directory
echo -e "\033[36m> Creating directory $HOME/$GZ_INSTALL_ROOT...\033[0m"
mkdir -p "$HOME/$GZ_INSTALL_ROOT"/src
chown -R "$USER": "$HOME/$GZ_INSTALL_ROOT" > /dev/null 2>&1

# Move to working directory
pushd "$HOME/$GZ_INSTALL_ROOT" || { 
    echo -e "\033[31m❌ Error: Failed to change to directory $HOME/$GZ_INSTALL_ROOT. \
    Please check if the directory exists and you have the necessary permissions.\033[0m"
    exit 1
}

# Activate virtual environment of ROS2 Jazzy
# shellcheck disable=SC1090
if [ -f "$HOME/$VIRTUAL_ENV_ROOT/bin/activate" ]; then
    source "$HOME/$VIRTUAL_ENV_ROOT/bin/activate"
else
    echo -e "\033[31m❌ Error: Virtual Environment at $HOME/$VIRTUAL_ENV_ROOT doesn't exist."
    echo -e "Please check ROS2 Jazzy installation\033[0m"
    exit 1
fi

# Confirm message
echo -e "\033[36m> Python Virtual Environment loaded\033[0m"

# ------------------------------------------------------------------------------
# Install Dendencies
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [2/6] Installing Dependencies with Brew and PIP\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Installing Gazebo Harmonic dependencies with brew
echo -e "\033[36m> Installing Gazebo Harmonic dependencies with Brew...\033[0m"
brew update
brew tap osrf/simulation
brew install libyaml libzip assimp boost bullet cmake cppzmq dartsim@6.10.0 doxygen \
     eigen fcl ffmpeg flann freeimage freetype gdal gflags google-benchmark \
     gts ipopt jsoncpp libccd libyaml libzzip libzip nlopt ode open-scene-graph \
     ossp-uuid ogre1.9 ogre2.3 pkg-config protobuf qt@5 qwt-qt5 rapidjson ruby \
     tbb tinyxml tinyxml2 urdfdom zeromq

# Install Python3.11 dependencies with pip
echo -e "\033[36m\n> Installing Python3.11 dependencies with PIP in virtual environment...\033[0m"
python3 -m pip install --upgrade pip
python3 -m pip install swig

# Confirm message
echo -e "\033[36m> Packages installation with PIP completed.\033[0m"

# Set Environment Variables of Brew packages
echo -e "\033[36m> Setting Environment Variables of Brew packages...\033[0m"
export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:/opt/homebrew/opt/dartsim@6.10.0
export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}:/opt/homoebrew/opt/dartsim@6.10.0/lib:/opt/homebrew/opt/octomap/local
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:/opt/homebrew/opt/dartsim@6.10.0/lib/pkgconfig
export CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:/opt/homebrew/opt/qt@5

# Install XQuartz
brew install xquartz --cask

# Confirm message
echo -e "\033[36m\n\n> Packages installation with Brew completed.\033[0m"

# ------------------------------------------------------------------------------
# Downloading Gazebo Harmonic Source Code
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [3/6] Downloading Gazebo Harmonic Source Code\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Reset git directories (git clean -d -f .) if they exist inside src directory
if [ -d "src" ]; then
    echo -e "\033[36m> Resetting git directories inside src...\033[0m"
    find src -name ".git" -type d -execdir bash -c 'if [ -d ".git" ]; then git clean -d -f .; fi' \;
fi

# Get Gazebo Harmonic  Source Code
echo -e "\033[36m\n> Getting Gazebo Harmonic Code...\033[0m"
echo -e "As long as the spinner at of the terminal is running, it is downloading the source code. It does take long."
echo -e "If you see 'E' in the progress, it means the download failed (slow connection does this), it will try again."
echo -e "If it takes too long, please check your network connection and try again. To cancel, Ctrl+C."
echo -e "\033[33mSTART--------END\033[0m"

# Define maximum number of retries
max_retries=3
# Start loop
for ((i=1;i<=max_retries;i++)); do
    # Try to import the repositories
    if vcs import --force --shallow --retry 0 \
        --input https://raw.githubusercontent.com/gazebo-tooling/gazebodistro/master/collection-harmonic.yaml src;
        then
        echo -e "\033[36m\n> Gazebo Harmonic Code Import Successful\033[0m"
        break
    else
        echo -e "\033[31m\nGazebo Harmonic Source Code Import failed, retrying ($i/$max_retries)\033[0m"
        echo -e "\033[33mSTART--------END\033[0m"
    fi
    # If we've reached the max number of retries, exit the script
    if [ $i -eq $max_retries ]; then
        echo -e "\033[31m\nGazebo Harmonic Source Code Import failed after $max_retries attempts, terminating script.\033[0m"
        exit 1
    fi
    # Wait before retrying
    sleep 5
done

# Fix brew linking of qt5
echo -e "\033[36m> Fixing brew linking of qt5...\033[0m"
brew unlink qt && brew link qt@5

# ------------------------------------------------------------------------------
# Building Gazebo Harmonic
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [5/6] Building Gazebo Harmonic (This may take about 15 minutes)\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
if ! python3.11 -m colcon build \
    --cmake-args -DBUILD_TESTING=OFF -DCMAKE_MACOSX_RPATH=FALSE -DBUILD_DOCS=OFF \
    -DPython3_EXECUTABLE="$HOME/$VIRTUAL_ENV_ROOT/bin/python3" -Wno-dev \
    --event-handlers console_cohesion+ --merge-install;
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
# Fix home directory permission (hope this is safe)
chmod o-w "$HOME"

# Remove empty gui.config (set to default if already exists)
if [ -f "$HOME/.gz/sim/8/gui.config" ]; then
    rm "$HOME/.gz/sim/8/gui.config"
fi

# save GZ_INSTALL_ROOT in a file
if [ -f "$HOME/.ros2_jazzy_install_config" ]; then
    echo "GZ_INSTALL_ROOT=$GZ_INSTALL_ROOT" >> "$HOME/.ros2_jazzy_install_config"
fi

# Download sentenv.sh
if [ -f setenv.sh ]; then
    rm setenv.sh
fi
if [ -f setenv_gz.sh ]; then
    rm setenv_gz.sh
fi
curl -s -O https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/setenv_gz.sh

# Replace string inside sentenv.sh
sed -i '' "s|ROS_INSTALL_ROOT|$ROS_INSTALL_ROOT|g" setenv_gz.sh
sed -i '' "s|VIRTUAL_ENV_ROOT|$VIRTUAL_ENV_ROOT|g" setenv_gz.sh
sed -i '' "s|GZ_INSTALL_ROOT|$GZ_INSTALL_ROOT|g" setenv_gz.sh

# Rename sentenv.sh to activate_ros
if [ -f "$HOME/$ROS_INSTALL_ROOT/activate_ros" ]; then
    rm "$HOME/$ROS_INSTALL_ROOT/activate_ros"
fi
mv setenv_gz.sh "$HOME/$ROS_INSTALL_ROOT/activate_ros"

# Print post messages
printf '\033[32m%.0s=\033[0m' {1..75} && echo
echo -e "\033[32m🎉 Done. Hurray! 🍎 (Apple Silicon) + 🤖 = 🚀❤️🤩🎉🥳 \033[0m"
echo
echo "To activate the new ROS2 Jazzy - Gazebo Harmonic framework, run the following command:"
echo -e "\033[32msource $HOME/$ROS_INSTALL_ROOT/activate_ros\033[0m"
echo -e "\nThen, try '\033[32mros2\033[0m' or '\033[32mrviz2\033[0m' in the terminal to start ROS2 Jazzy."
echo -e "\nTo test gazebo, \033[33mrun following commands separately in two termianls (one for server(-s) and one for gui(-g))"
echo -e "\033[31m(IMPORTANT, both terminals should have \033[0m'source $HOME/$VIRTUAL_ENV_ROOT/activate_ros'\033[31m activated)\033[0m"
# shellcheck disable=SC2016
echo -e "  [1st Terminal with ($VIRTUAL_ENV_ROOT)]\033[32m gz sim shapes.sdf -s \033[0m"
echo -e "  [2nd Terminal with ($VIRTUAL_ENV_ROOT)]\033[32m gz sim -g \033[0m"
printf '\033[32m%.0s=\033[0m' {1..75} && echo
echo "To make alias for fast start, run the following command to add to ~/.zprofile:"
echo -e "\033[34mecho 'alias ros=\"source $HOME/$ROS_INSTALL_ROOT/activate_ros\"' >> ~/.zprofile && source ~/.zprofile\033[0m"
echo
echo -e "Then, you can start ROS2 Jazzy - Gazebo Harmonic framework by typing '\033[34mros\033[0m' in the terminal (new terminal)."
echo -e "You may change the alias name to your preference in above alias command."
echo
echo "To deactivate this workspace, run:"
echo -e "\033[33mdeactivate\n\n\033[0m"

# popd || exit
