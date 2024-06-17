#!/bin/bash
echo -e "Do you want to install Gazebo Harmonic too? (y/n)"
read -r response

ROS_INSTALL_ROOT="ros2_jazzy"
VIRTUAL_ENV_ROOT=".ros2_venv"
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\033[36m> Installing Gazebo Harmonic...\033[0m"
    # /bin/bash -c /Users/woensug/Github/ROS2_Jazzy_MacOS_Native_AppleSilicon/gz_install.sh -r "ros2_jazzy" -v ".ros2_jazzy"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/gz_install.sh)" \
        -- -r $ROS_INSTALL_ROOT -v $VIRTUAL_ENV_ROOT
fi