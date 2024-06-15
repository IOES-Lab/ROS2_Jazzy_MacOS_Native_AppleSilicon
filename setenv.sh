#!/bin/bash
# From https://github.com/pfavr2/install_ros2_rolling_on_mac_m1

# After running - you need to activate:

# Grab old environment
# shellcheck disable=SC2155
export OLD_ENV="$(export -p)"

# Clean current environment and restore old environment from before activating
function deactivate_ros() {
  if typeset -f deactivate > /dev/null; then
    deactivate
  fi
  for var in $(env | awk -F= '{print $1}' | grep -o '[^ ]*$'); do 
    if [ "$var" != "OLD_ENV" ]; then
      # echo "Removing var [$var]"
      unset "$var"
    fi
  done
  # shellcheck disable=SC2059
  # shellcheck disable=SC1091
  printf "$OLD_ENV" | source /dev/stdin
  unset OLD_ENV
  unset -f deactivate_ros
}

# Source Virtual Environment
    # shellcheck disable=SC1090
source "$HOME/$VIRTUAL_ENV_ROOT/bin/activate"

# Source ROS
if [[ $SHELL == *"bash"* ]]; then
    # shellcheck disable=SC1090
    source "$HOME/$ROS_INSTALL_ROOT/install/setup.bash"
elif [[ $SHELL == *"zsh"* ]]; then
    # shellcheck disable=SC1090
    source "$HOME/$ROS_INSTALL_ROOT/install/setup.zsh"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi