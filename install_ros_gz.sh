#!/bin/bash
# ROS_GZ installation script

# Read variables from the config file
# shellcheck disable=SC1091
source "$HOME/.ros2_jazzy_install_config"

# Now you can use the variables in your script
echo "Virtual Environment Root: $VIRTUAL_ENV_ROOT"
echo "ROS Install Root: $ROS_INSTALL_ROOT"

# Source ROS Installation
# shellcheck disable=SC1090
source "$HOME/$ROS_INSTALL_ROOT/activate_ros"



