#!/bin/bash
# Source Virtual Environment

# shellcheck disable=SC1091
source "$HOME/VIRTUAL_ENV_ROOT/bin/activate"

# Add CMAKE path for Qt5
CMAKE_PREFIX_PATH=$(brew --prefix qt@5)/lib/cmake:/opt/homebrew/opt:${CMAKE_PREFIX_PATH}

# Gazebo runtime root
export GZ_ROOT="$HOME/gz_harmonic/install"

# Use Homebrew Ruby before macOS system Ruby
# shellcheck disable=SC2155
export PATH="$(brew --prefix ruby)/bin:$PATH"

# Gazebo / Homebrew dynamic libraries
export DYLD_LIBRARY_PATH="$GZ_ROOT/lib:/opt/homebrew/lib:/opt/homebrew/opt/qt@5/lib:$DYLD_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$GZ_ROOT/lib:/opt/homebrew/lib:/opt/homebrew/opt/qt@5/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# Source ROS
if [[ $SHELL == *"bash"* ]]; then
    # shellcheck disable=SC1091
    source "$HOME/ROS_INSTALL_ROOT/install/setup.bash"
    # shellcheck disable=SC1091
    source "$HOME/GZ_INSTALL_ROOT/install/setup.bash"
elif [[ $SHELL == *"zsh"* ]]; then
    # shellcheck disable=SC1091
    source "$HOME/ROS_INSTALL_ROOT/install/setup.zsh"
    # shellcheck disable=SC1091
    source "$HOME/GZ_INSTALL_ROOT/install/setup.zsh"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi

# Start ROS2 Daemon
ros2 daemon start