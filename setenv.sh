#!/bin/bash
# Source Virtual Environment

# shellcheck disable=SC1091
source "$HOME/VIRTUAL_ENV_ROOT/bin/activate"

# Source ROS
if [[ $SHELL == *"bash"* ]]; then
    # shellcheck disable=SC1091
    source "$HOME/ROS_INSTALL_ROOT/install/setup.bash"
elif [[ $SHELL == *"zsh"* ]]; then
    # shellcheck disable=SC1091
    source "$HOME/ROS_INSTALL_ROOT/install/setup.zsh"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi